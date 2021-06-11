此文是平时工作中学习和踩坑记录，比较杂乱，有不对的地方，还请各位大佬指点。

**我的GitHub地址**：[https://github.com/liu5656/MultistageBar](https://github.com/liu5656/MultistageBar)

# 1、alloc和init

[参考文章：https://www.jianshu.com/p/b72018e88a97](https://www.jianshu.com/p/b72018e88a97)



### 1.1、alloc

调用流程：调用类方法alloc --> _objc_rootAlloc --> callAlloc --> _objc_rootAllocWithZone --> _class_createInstanceFromZone --> cls->instanceSize计算需要开辟的内存的大小 --> calloc申请内存 --> obj-initInstanceIsa将cls类和obj指针相关联 --> 返回本身



# 2、原生接入H5支付

**原理：**通过遵守WKWebView的navigationDelegate协议，通过`**func** webView(**_** webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: **@escaping** (WKNavigationActionPolicy) -> Void)`接口，通过对`navigationAction.request.ur`获取到的url进行处理，如http://、alipay://、weixin://的修改，然后再原生调用微信或支付宝。

## 2.1、支付宝

1. 先通过`navigationAction.request.url`获取到url
2. 检查url中是否以`https://openapi.alipay.com`开头，如否则进入第四步，如是，便获取`query`中的`return_url`的值保存为**全局变量**方便后续回调，需要提前设置监听应用进入前台的通知。
3. 允许此请求进行`decisionHandler(.allow)`，然后return
4. 检查url是否以`alipay`开头，则替换`query`中的`fromAppUrlScheme`字段，替换的值为xxx.注册H5支付的商家的二级域名或三级域名.com，其中的xxx可根据自己的平台设置，还需要在工程配置中info --> URL Types中添加对应的`fromAppUrlScheme`的值，方便支付结果回调。
5. 拒绝此请求`decisionHandler(.cancel)`
6. 通过Application.shared打开这条修改后的url，然后return
7. 支付结果回调，触发应用进入前台通知，使用该webview调用第二步保存的地址。

部分代码如下：

```swift
if urlStr.hasPrefix(zfbCheckmweb),
                   let components = URLComponents.init(string: urlStr),
                   let temp = components.queryItems?.first(where: {$0.name == "return_url"})?.value {
                    redirectURL = temp          // 保存到全局变量
                }
                if urlStr.hasPrefix("alipay") {
                    decisionHandler(.cancel)
                    let components = urlStr.components(separatedBy: "?")
                    guard let first = components.first, var last = components.last?.toJson() as? [String: Any] else {
                        return
                    }
                    last["fromAppUrlScheme"] = "自定义的字段.h5支付商户的二级或三级域名.com"
                    guard let suffix = last.jsonString()?.encodeURL(),
                          let temp = URL.init(string: first + "?" + suffix) else {
                        return
                    }
                    UIApplication.shared.open(temp, options: [:], completionHandler: nil)
                    return
                }
```



## 2.2、微信

1. 检查url中是否`redirect_url=`并且不以`wxpaycallback/`(这个值可自定义)结尾，如否，进入第三步；
2. 如是，则先保存redirect_url的原始值，方便支付结果回调后，监听应用进入前台，触发webview去检查订单
3. 然后替换query中的`redirect_url`的值，值的格式为xxx.注册H5支付的商家的二级域名或三级域名.com，xxx可自定义。
4. 取消该请求decisionHandler(.cancel)
5. 获取替换了redirect_url的原始链接，新建一个请求，用同一webview发起，然后return
6. 检查获取到的url是否以`weixin://`开头，如是，则调用Application.shared打开
7. 支付回调后，如果回调变量有值，webview加载回调地址变量，检查订单结果。

```swift
if urlStr.contains(redirectURLPrefix),
                   urlStr.hasSuffix(redirectURLSuffix) == false,
                   let prefix = urlStr.components(separatedBy: redirectURLPrefix).first,
                   let suffix = urlStr.components(separatedBy: redirectURLPrefix).last,
                   let host = URL.init(string: suffix)?.host,
                   let index = try? host.firstIndex(of: ".") {
                    // 组装回调地址
                    let domain: String
                    if host.contains("H5支付商户的二级域名（如baidu）") {
                        domain = String(host.suffix(from: index))
                    }else{
                        domain = "." + host
                    }
                    redirectURL = suffix
                    if let newUrl = URL.init(string: prefix + "redirect_url=ypj1" + domain + "://" + redirectURLSuffix) {
                        var req = URLRequest.init(url: newUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
                        req.allHTTPHeaderFields = navigationAction.request.allHTTPHeaderFields
                        decisionHandler(.cancel)
                        webView.load(req)
                        return
                    }
                }
                if urlStr.hasPrefix("weixin://") {
                    decisionHandler(.cancel)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }else{
                    decisionHandler(.allow)
                }
```

## 2.3、原生H5支付完整代码

```swift
private let redirectURLSuffix = "wxpaycallback/"
private let redirectURLPrefix = "redirect_url="
private let wxCheckmweb = "https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb"
private let zfbCheckmweb = "https://openapi.alipay.com"

extension XXWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, let urlStr = url.absoluteString.removingPercentEncoding  {
                DDLLog(urlStr)
                if urlStr.hasPrefix(zfbCheckmweb),
                   let components = URLComponents.init(string: urlStr),
                   let temp = components.queryItems?.first(where: {$0.name == "return_url"})?.value {
                    redirectURL = temp          // 保存到全局变量
                }
                if urlStr.hasPrefix("alipay") {
                    decisionHandler(.cancel)
                    let components = urlStr.components(separatedBy: "?")
                    guard let first = components.first, var last = components.last?.toJson() as? [String: Any] else {
                        return
                    }
                    last["fromAppUrlScheme"] = "自定义的字段.h5支付商户的二级或三级域名.com"
                    guard let suffix = last.jsonString()?.encodeURL(),
                          let temp = URL.init(string: first + "?" + suffix) else {
                        return
                    }
                    UIApplication.shared.open(temp, options: [:], completionHandler: nil)
                    return
                }
                
                if urlStr.contains(redirectURLPrefix),
                   urlStr.hasSuffix(redirectURLSuffix) == false,
                   let prefix = urlStr.components(separatedBy: redirectURLPrefix).first,
                   let suffix = urlStr.components(separatedBy: redirectURLPrefix).last,
                   let host = URL.init(string: suffix)?.host,
                   let index = try? host.firstIndex(of: ".") {
                    // 组装回调地址
                    let domain: String
                    if host.contains("H5支付商户的二级域名（如baidu）") {
                        domain = String(host.suffix(from: index))
                    }else{
                        domain = "." + host
                    }
                    redirectURL = suffix
                    if let newUrl = URL.init(string: prefix + "redirect_url=ypj1" + domain + "://" + redirectURLSuffix) {
                        var req = URLRequest.init(url: newUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5)
                        req.allHTTPHeaderFields = navigationAction.request.allHTTPHeaderFields
                        decisionHandler(.cancel)
                        webView.load(req)
                        return
                    }
                }
                if urlStr.hasPrefix("weixin://") {
                    decisionHandler(.cancel)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }else{
                    decisionHandler(.allow)
                }
            }else{
                decisionHandler(.allow)
            }
        }
}
```

# 3、获取照片

使用photos框架

## 3.1、获取图片资源

`Photos`提供`PHAsset`类来获取所有的资源对象，查询条件通过`PHFetchOptions`来控制，如通过创建时间等，返回的结果集可以通过遍历获取所有的资源

```swift
lazy var fetchResults: PHFetchResult<PHAsset> = {
        let option = PHFetchOptions.init()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResults = PHAsset.fetchAssets(with: option)
        return fetchResults
    }()
```

## 3.2、PHAsset

**重要属性：**`PHAsset`有几个大类：图片、视频、音频和其他类型，图片和视频大类下面还分小类，如图片`photoPanorama`、`photoHDR`、`photoScreenshot`、`photoLive`、`photoDepthEffect`，视频分`videoStreamed`、`videoHighFrameRate`，`videoTimelapse`；如果是视频还包含有视频的时间，图片的的像素宽高等。

## 3.3、通过PHAsset获取对应资源

`PHCachingImageManager`继承`PHImageManager`，可以获取PHAsset对应的资源；可以自建或使用`PHCachingImageManager.default()`默认对象，这里使用默认对象。

```swift
if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [temp], options: nil).firstObject {
            let option = PHImageRequestOptions.init()
            option.isNetworkAccessAllowed = true
            PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: mode, options: option) { (img, info) in
                if let value = info?[PHImageErrorKey] as? NSError {
                    callback(nil, false, value)
                    // 81 超时
                    // 82 飞行模式
                    // 1005 存储空间不足
                }else if let value = info?[PHImageCancelledKey] as? Bool, value == true {
                    callback(nil, false, NSError.init())
//                    MBLog("操作已取消!")
                }else if let value = info?[PHImageResultIsDegradedKey] as? Bool, value == true {
                    callback(img, false, nil)
//                    MBLog("获取到缩略图!")
                }else if let temp = img {
                    callback(temp, true, nil)
//                    MBLog("获取到原图!")
                }else{
                    callback(nil, false, NSError.init())
//                    MBLog("操作错误")
                }
            }
        }
```

# 4、优化

## 4.1、启动优化

[参考网址：https://juejin.cn/post/6898630576031399944](https://juejin.cn/post/6898630576031399944)

iOS启动速度检测:

```
Total pre-main time: 320.69 milliseconds (100.0%)
         dylib loading time:  90.62 milliseconds (28.2%)
        rebase/binding time:  20.84 milliseconds (6.4%)
            ObjC setup time:  28.60 milliseconds (8.9%)
           initializer time: 180.62 milliseconds (56.3%)
           slowest intializers :
             libSystem.B.dylib :   4.93 milliseconds (1.5%)
   libBacktraceRecording.dylib :   8.37 milliseconds (2.6%)
    libMainThreadChecker.dylib :  55.05 milliseconds (17.1%)
                       KSAdSDK :  37.56 milliseconds (11.7%)
                     洋皮卷 : 109.62 milliseconds (34.1%)
```

- 打印main函数之前的的时间：Edit scheme -> Run -> Arguments添加环境变量DYLD_PRINT_STATISTICS
- dylib动态库的加载时间，主要对第三方动态库优化，苹果建议自定义的动态库不要超过6个
- rebase偏移修正，编写的代码中的函数和属性都有基于ASLR的相对地址，加载进内存时会加上ASLR才能访问到真正的地址
- binding符号绑定，mach-O文件中创建随机符号和方法的偏移地址关联，
- Objc setup time这一步主要是类的加载，分类的合并，保证每个selelctor的唯一
  - 优化方案，合并、删除OC类，清理未使用的类，方法，变量
- initializer time这里主要做的是load和构造函数（这里的构造函数是指c++）的实现
  - 优化方案：推迟到启动之后，尽量少使用load方法和c++的构造函数，将不必须在+load方法中做的事情延迟到+initialize中

```objc
NSObject *objc = [NSObject alloc];
// %p -> objc 对象指针所指向的内存地址
// %p -> &objc 对象的指针地址
NSLog(@"%@ -- %p -- %p", objc, objc, &objc);
// 输出如下
// 2020-12-22 14:04:32.133838+0800 KCObjcTest[8393:163260] <NSObject: 0x101e1da10> -- 0x101e1da10 -- 0x7ffeefbff570
```



# 5、Runtime & Runloop

## 5.1、消息传递

**[receiver message];** **消息直到运行时才绑定到具体实现**

编译器转换消息表达式，将接收方（receiver）和用方法名称（message）配置的方法选择器（selecter）作为其两个主要参数

```objective-c
objc_msgSend(reciver, selecter);										// 不带参数
objc_msgSend(reciver, selecter， arg1, arg2,...); 		// 传递的参数也会传递给objc_msgSend
```

**消息传递函数为动态绑定：**

1. 先绑定查找选择器引用的的过程，因为同一个方法可以由不同的类来实现，精确过程取决于接受方（receiver）。
2. 
3. 

### 5.1.1、消息传递的准备

消息传递的关键在于，**编译器为每个类结构和对象结构：**

1. 类结构都包含两个基本元素
   1. 指向超类的指针
   2. 类调度表，**表中的条目将方法选择器（selector）与它标识的方法的类的特定地址相关联**，如setOrigin:方法的选择器与setOrigin:实现过程的地址相关联
2. 对象结构
   1. 创建新对象时，将为起分配内存，并初始化实例变量
   2. 对象变量中的第一个变量isa是指向其类结构的指针，对象通过isa访问对应类，通过对应类可以访问其继承的类。

### 5.1.2、消息传递过程（方法是动态绑定到消息的）

为了加快消息传递过程，**运行时系统在使用方法时会缓存选择器和地址**，每个类都有一个单独的缓存。

1. 当消息传递到对象时，首先检查接收对象类的缓存，有就直接使用，没有就开始查找。
2. 消息传递函数跟随对象的isa指针对应的类结构，类结构对应的调度表中查询对应的方法选择器（selector）。
3. 如果当前类的调度表中找不到，则到超类的调度表中去查询。
4. 一旦找到选择器，就会调用表中输入的方法，并将接受对象的数据结构传递给它。

### 5.1.3、如何避免动态绑定

如果希望避免每次执行改方法时消息传递的开销，可以采用规避动态绑定的方法，通过获取方法地址，然后像函数一样直接调用它。

继承NSObject的类的实例对象，通过**methodForSelector:**方法可以得到方法实现的指针，然后再用该指针调用该过程，methodForSelector:放回的指针类型的参数列表为包含了接受对象（self）和方法选择器（_cmd），这些参数隐藏在方法语法中，但显式调用是需要明确显示

## 5.2、消息转发

流程：

**resolveInstanceMethod或resolveClassMethod -> forwardingTargetForSelector -> forwardInvocation -> doesNotRecognizeSelector抛出异常**

[参考网址：https://www.jianshu.com/p/ee19f969c2d4](https://www.jianshu.com/p/ee19f969c2d4)

- resolveInstanceMethod:	为实例方法的给定选择器提供实现
- resolveClassMethod:    为类方法的给定选择器提供实现

消息转发是在查找IMP失败后执行的一系列动作，如果不做转发处理，会导致应用崩溃，

1. 对象或类收到无法解读的消息后，会回调**resolveInstanceMethod或resolveClassMethod**方法来询问，是否有动态添加方法来进行处理，如果对类或实例通过class_addMethod添加方法，则返回YES表明能接受消息；如果返回NO不能接受消息，则进入下个步骤。

2. 回调**forwardingTargetForSelector**方法，是否有备用对象能处理，能处理就返回备用对象。

3. 如果第二不返回self或nil，系统回调**methodSignatureForSelector**返回sel方法的签名，签名是根据sel的参数来封装的；[签名规则地址](https://blog.csdn.net/ssirreplaceable/article/details/53376915)。

   1. ```objective-c
      - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
           //例子"v@:@"
           //v@:@ v 返回值类型void;@ id类型,执行sel的对象;: SEL;@ 参数
           //例子"@@:"
           //@ 返回值类型id;@ id类型,执行sel的对象;: SEL
           */
          //如果返回为nil则进行手动创建签名
          if ([super methodSignatureForSelector:aSelector]==nil) {
              NSMethodSignature * sign = [NSMethodSignature signatureWithObjCTypes:"v@:"];
              return sign;
          }
          return [super methodSignatureForSelector:aSelector];
          
      }
      
      ```

4. 如果未处理，则抛出异常

参考：

- [消息转发实现OC多重代理：https://blog.csdn.net/kingjxust/article/details/49559091](https://blog.csdn.net/kingjxust/article/details/49559091)

- [间接实现多继承：https://www.jianshu.com/p/9601e84177a3](https://www.jianshu.com/p/9601e84177a3)
- [https://www.jianshu.com/p/9263720cbd91](https://www.jianshu.com/p/9263720cbd91)

## 5.3、Runloop

[参考网址：https://blog.csdn.net/u013480070/article/details/100154619](https://blog.csdn.net/u013480070/article/details/100154619)

[参考网站：http://www.itpub.net/2019/10/29/3869/](http://www.itpub.net/2019/10/29/3869/)

​		Runloop是为了保持某个线程不结束，只要还有未结束的线程，整个程序就不会退出，因为线程是程序的运行和调度的基本单元，Runloop会在没有事件发生时休眠，从而不会占用CPU消耗，有事件才会去找对应的hanler处理事件。

​		Runloop和线程是的关系是一对一的，一个新创建的线程是没有Runloop的，当我们在该线程第一次通过相应API获取Runloop的时候，Runloop才会被创建，并且通过一个全局字典将该线程和Runloop对象一一对应，线程为key，Runloop对象为value。

​		Runloop会在线程结束时销毁，UIApplicationMain()方法会默认为主线程创建一个NSRunLoop对象，这个对象会监听屏幕上的点击，子线程默认是没有开启Runloop

### 5.3.1、相关API

- Foundation：NSRunloop
- Core Foundation：CFRunloopRef

两者都代表Runloop对象，只是NSRunloop是CFRunloopRef的OC封装，

Runloop对象的获取，

```objective-c
    [NSRunLoop currentRunLoop]; // 获取当前线程的runloop
    [NSRunLoop mainRunLoop];    // 获取主线程的runloop
    CFRunLoopGetCurrent();
    CFRunLoopGetMain();

```

### 5.3.2、Runloop的获取流程

1. 从CFRunLoopGetCurrent方法里面调用_CFRunLoopGet0返回Runloop对象。
2. 先判断全局字典是否创建，没有就创建。
3. 从全局字典里面以线程为key获取Runloop对象，有就直接返回对象
4. 没有就创建Runloop对象，以线程为key加入全局字典对象
5. 返回新创建的Runloop对象

### 5.3.3、Runloop相关的类

##### Runloop苹果文档中有五种模式：

1. NSDefaultRunLoopMode(默认模式)
2. UITRackingRunLoopMode（UI模式）
3. NSRunLoopCommonModes（占位模式），其实占位模式不是一个真正的模式，它相当于上面两种模式之和。
4. NSDefaultRunLoopMode（kCFRunLoopDefaultMode） 
5. NSRunLoopCommonModes（kCFRunLoopCommonModes）

**Runloop有四种处理事件类型**

1. source0——包括 触摸事件处理、`[performSelector: onThread: ]`
2. source1——包括 基于Port的线程间通信、系统事件捕捉
3. observer——**Runloop**状态变更的时，会通知监听者进行函数回调，UI界面的刷新就是在监听到Runloop状态为**BeforeWaiting**时进行的。
4. Timer——包括我们设置的定时器事件、`[performSelector: withObject: afterDelay:]`

##### 与Runloop相关的类

- **CFRunLoopRef**——这个就是Runloop对象
- **CFRunLoopModeRef**——一个对象内部主要包括四个容器，分别用来存放四种模式（source0、source1、observer、timer）
- **CFRunLoopSourceRef**——分为`source0`和`source1`
- **CFRunLoopTimerRef**——`timer`事件，
- **CFRunLoopObserverRef**——监听者，

[CF源码文件网址：https://opensource.apple.com/tarballs/CF/](https://opensource.apple.com/tarballs/CF/)

可以在源码文件CFRunloop.c中找到Runloop的定义。一个Runloop对象通过**_modes**属性包含若干个**RunloopMode**容器，一个RunloopMode内部核心是四个数组容器，分别用来装**source0、source1、observer以及timer**，Runloop内部有个**_currentMode**，指向其中一个RunloopMode，表明当前Runloop只会执行_currentMode里面包含的事件。

### 5.3.4、滑动屏幕时定时器不回调

**定时器回调原理：**其实是scheduledTime。。。方法内部每隔定时器指定的时间就向当前线程的runloop对象内的DefaultMode容器添加timer事件到**timer容器**，然后在runloop的循环中，依次处理。

**为什么定时器不回调呢？**

一个RunloopRef对象内部有多个RunloopModeRef，其中有两个比较重要：

- KCFRunLoopDefaultMode，APP的默认mode，通常主线程在这个Mode下运行
- UITrackingRunloopMode，如果界面有ScrollView的滑动事件，会放在该Mode的事件容器里，当滑动时，APP会切换到该Mode下处理滑动事件。

所以滑动的时候主线程的Runloop对象切换到UITrackingRunloopMode，而定时器又只被加入到defaultMode里面，自然定时器就不会回掉了；当用户不滑动屏幕的时候，又恢复到DefaultMode，定时器就又回调了。Runloop划分不同的Mode的好处是分开耗时大的事件和滑动事件，对事件分开处理，避免界面卡顿。

**解决滑动界面不回调方法**

创建NSTimer时，将Timer对象加入到NSRunloopModes中`[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];`，NSRunloopModes不是某一个Mode，而是指被标记了的Mode，这种Mode会被放在Runloop对象的`_commonModes`里面，这个变量是`CFMutableSetRef`，默认情况下，`_commonModes`装有UITrackingRunloopMode和KCFRunLoopDefaultMode两个Mode，此时timer对象将不会放在某一个具体的Mode里，而是放在Runloop对象的`_commonModeItems`容器，当前Mode自己本身所包含的事件也会处理。

### 5.3.5、Runloop运行流程

通过分析`CFRunLoop.c`文件

```objc
SInt32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {     /* DOES CALLOUT */
    //🔉🔉🔉🔉***①***🔉🔉🔉🔉通知observer----------kCFRunLoopEntry
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopEntry);
    //⚙️⚙️⚙️⚙️启动runloop
    result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
    //🔉🔉🔉🔉***⑫***🔉🔉🔉🔉通知observer----------kCFRunLoopExit
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
    return result;
}

static int32_t __CFRunLoopRun(CFRunLoopRef rl, CFRunLoopModeRef rlm, CFTimeInterval seconds, Boolean stopAfterHandle, CFRunLoopModeRef previousMode) {
    //⚠️⚠️⚠️退出do-while循环的标签retVal
    int32_t retVal = 0;
    //♥️♥️♥️runloop的核心就是这样一个do-while循环
    do {
      //🔉🔉🔉🔉***②***🔉🔉🔉🔉通知observer-----kCFRunLoopBeforeTimers
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);
      //🔉🔉🔉🔉***③***🔉🔉🔉🔉通知observer-----kCFRunLoopBeforeSources
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);
      //⚙️⚙️⚙️⚙️***④***⚙️⚙️⚙️⚙️处理Blocks
	   __CFRunLoopDoBlocks(rl, rlm);
      //⚙️⚙️⚙️⚙️***⑤***⚙️⚙️⚙️⚙️处理source0-------
        Boolean sourceHandledThisLoop = __CFRunLoopDoSources0(rl, rlm, stopAfterHandle);
        if (sourceHandledThisLoop) {
            //⚙️⚙️⚙️⚙️⚙️⚙️⚙️⚙️需要的话处理Blocks
            __CFRunLoopDoBlocks(rl, rlm);
        }
      //♦️♦️♦️♦️***⑥***♦️♦️♦️♦️判断有没有source1
        if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
            //♦️♦️♦️♦️如果有source1，跳转到标签handle_msg处
            goto handle_msg;
        }
      //🔉🔉🔉🔉***⑦***🔉🔉🔉🔉通知observer-----kCFRunLoopBeforeWaiting
	   __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);

      //开始休眠
	  __CFRunLoopSetSleeping(rl);

      //等待别的消息来唤醒当前线程    
      __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
            
      //线程唤醒
	  __CFRunLoopUnsetSleeping(rl);


     //🔉🔉🔉🔉***⑧***🔉🔉🔉🔉通知observer-----kCFRunLoopAfterWaiting 结束休眠
      __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);

//⚙️⚙️⚙️⚙️
handle_msg://⚙️⚙️⚙️⚙️***⑨***⚙️⚙️⚙️⚙️处理唤醒事件

        //♦️♦️♦️♦️被timer唤醒
        if (rlm->_timerPort != MACH_PORT_NULL && livePort == rlm->_timerPort) {
        //⚙️⚙️⚙️⚙️处理timer
            __CFRunLoopDoTimers(rl, rlm, mach_absolute_time())
        }
        //♦️♦️♦️♦️被GCD唤醒
        else if (livePort == dispatchPort) {
        //⚙️⚙️⚙️⚙️处理GCD
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            
        } 
        //♦️♦️♦️♦️source1唤醒
        else {
        //⚙️⚙️⚙️⚙️处理Source1
            __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
	    }

      //⚙️⚙️⚙️⚙️***⑩***⚙️⚙️⚙️⚙️处理Blocks
	   __CFRunLoopDoBlocks(rl, rlm);
        
      //⚙️⚙️⚙️⚙️***⑪***⚙️⚙️⚙️⚙️设置返回值retVal
	  if (sourceHandledThisLoop && stopAfterHandle) {
	      retVal = kCFRunLoopRunHandledSource;
          } else if (timeout_context->termTSR < mach_absolute_time()) {
              retVal = kCFRunLoopRunTimedOut;
	  } else if (__CFRunLoopIsStopped(rl)) {
              __CFRunLoopUnsetStopped(rl);
	      retVal = kCFRunLoopRunStopped;
	  } else if (rlm->_stopped) {
	      rlm->_stopped = false;
	      retVal = kCFRunLoopRunStopped;
	  } else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
	      retVal = kCFRunLoopRunFinished;
	  }
        
  } while (0 == retVal);
    
  return retVal;
}

```

### 5.3.6、线程的休眠细节

__CFRunLoopServiceMachPort是一种真正意义上的休眠，让线程真正停下来，不再消耗CPU做停留，内部调用mach_msg()函数，内部可能会通过中断的方式来唤醒。

# 6、状态栏、导航栏、标签栏

info.plist文件添加View controller-based status bar appearance字段：

- 值为true，则各个控制器之间不影响；ViewController对状态栏的设置优先级高于application的设置。
- 值为false，则控制器之间相互影响；以application设置为准，ViewController的preferredStatusBarStyle不会主动调用。

## 1、修改状态栏颜色

参考：https://blog.csdn.net/todovista/article/details/108689202

1. 未使用导航控制器的情况，只需要在ViewController中重写preferredStatusBarStyle只读属性，返回当前控制器需要的状态就可以

2. 使用系统的导航控制器的情况，即使在控制器中重写preferredStatusBarStyle的只读属性，并且主动调用setNeedsStatusBarAppearanceUpdate()方法，preferredStatusBarStyle属性也不会被调用，因为此时的状态栏是根据导航栏来自动变换的；要改变状态栏的颜色只需要主动修改导航栏的样式就可以了

   ```swift
   	navigationController?.navigationBar.barStyle = .black		// 状态栏将变白色
   ```

3. 使用自定义的导航控制器的情况，首先需要在自定义的导航控制器中重写childForStatusBarStyle的只读属性，

   ```swift
   // 告诉系统,调用topViewControll的preferredStatusBarStyle属性值来更新状态栏
   override var childForStatusBarStyle: UIViewController? {
           return topViewController
       }
   ```

   然后在需要改变颜色的ViewController中重写preferredStatusBarStyle的只读属性即可。

   ```swift
   override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }
   ```

## 2、导航栏

一个导航控制器只有一个导航栏，也就是说同一个导航控制器中的ViewController修改导航栏后会影响其他的控制器。

1. 修改导航栏的背景图

   ```swift
   let backgroundImage = UIImage.drawImage(withColor: .FFFFFF, size: CGSize(width: Screen.width, height: Screen.fakeNavBarHeight))
           navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
   ```

2. 修改导航栏底部黑线

   ```swift
   let shadowImage = UIImage.drawImage(withColor: .F1F1F1, size: CGSize(width: Screen.width, height: 0.5.flatScale))
           navigationController?.navigationBar.shadowImage = shadowImage
   ```

3. 修改导航栏标题样式

   ```swift
   navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor._282828, .font:UIFont.fontBold16()]
   ```

# 7、物理仿真

**UIDynamic方正流程：**

1. 创建物理仿真器（UIDynamicAnimator）实例，并设置仿真范围。
2. 创建物理仿真行为，添加物理仿真元素。
3. 将物理仿真行为添加到仿真器中，开始仿真。

**仿真元素**

任何遵守UIDynamicItem协议的对象才能作为仿真元素，UIView、UICollectionViewLayoutAttributes类已经遵守了UIDynamicItem协议。

**物理仿真行为**

- 重力：UIGravityBehavior
- 碰撞：UICollisionBehavior
- 推动：UIPushBehavior
- 动力元素：UIDynamicItemBehavior
- 附着：UIAttachmentBehavior
- 捕捉：UISnapBehavior

# 8、HTTPS

**参考文章：**

[iOS Https证书验证问题全解](https://www.jianshu.com/p/3ff885ec989e)

[Java Keytool生成数字证书/.cer/.p12文件](https://blog.csdn.net/devil_bye/article/details/82759140)

[SecCertificate,SecKey,SecTrust详解](https://www.jianshu.com/p/af7ad3105ed2)

[IOS Swift Https单向认证](https://blog.csdn.net/ZZB_Bin/article/details/73135506)

[Swift、WKWebView 适配HTTPS（单向验证）](https://www.jianshu.com/p/6dbe8bd7782c)

## 客户端校验服务端

### 完全信任

```swift
// 不验证服务端,直接全部信任
    func trustRemoteAlways(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        var cre: URLCredential?
        if let trust = challenge.protectionSpace.serverTrust {
            cre = URLCredential.init(trust: trust)
        }
        return (disposition, cre)
    }
```

### 对远端服务进行证书校验

```swift
// 对服务器发过来的证书进行验证
    func verifyRemoteWithCer(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard let remotePackage = challenge.protectionSpace.serverTrust,
              let remoteCerti = SecTrustGetCertificateAtIndex(remotePackage, 0),
              let localPath = Bundle.main.path(forResource: "server", ofType: "cer") else {
            return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        let remoteCertiData = SecCertificateCopyData(remoteCerti) as Data
        let localUrl = URL.init(fileURLWithPath: localPath)
        let localCertiData = try? Data.init(contentsOf: localUrl)
        let disposition: URLSession.AuthChallengeDisposition
        var credential: URLCredential? = nil
        if remoteCertiData == localCertiData {
            disposition = URLSession.AuthChallengeDisposition.useCredential
            credential = URLCredential.init(trust: remotePackage)
        }else{
            disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
        }
        return (disposition, credential)
    }
```

## 提供证书以便服务端验证客户端

**注意：**此处的证书格式需要为p12，否则获取证书会失败（-26275错误码）

```swift
// 获取本地p12文件以供远端校验
    func retrieveLocalCredential() -> URLCredential? {
        let certificationName = "client.p12"
        let certificationPassword = "123456"
        guard let localPath = Bundle.main.path(forResource: certificationName, ofType: nil) else {
            return nil
        }
        
        let localUrl = URL.init(fileURLWithPath: localPath)
        
        guard let pkcs12 = try? Data.init(contentsOf: localUrl) as CFData else {
            return nil
        }
        
        let options = [kSecImportExportPassphrase: certificationPassword] as CFDictionary
        var items: CFArray?
        let result = SecPKCS12Import(pkcs12, options, &items)
        
        guard result == errSecSuccess,
              let info = (items! as Array).first as? [String: Any] else {
            return nil
        }
        
        let identify = info["identity"] as! SecIdentity
        let certificates = info["chain"] as? [Any]
        let type = URLCredential.Persistence.forSession
        
        return URLCredential.init(identity: identify, certificates: certificates, persistence: type)
    }
```









