//
//  MBCustomObject.m
//  MultistageBar
//
//  Created by x on 2020/12/11.
//  Copyright © 2020 x. All rights reserved.
//

#import "MBCustomObject.h"
#import <objc/runtime.h>
#import "MultistageBar-Swift.h"

@implementation MBCustomObject

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(resolveClassMethod:)) {
//        return YES;
//    }
//    return NO;
//}
void dynamicMethodIMP(id self, SEL _cmd) {
    char *buf1 = @encode(int **);
//    @encode(char *);
    id temp = objc_getClass("MBCustomObject");
    unsigned int count;
     objc_property_t *properties = class_copyPropertyList(temp, &count);
    
    [NSRunLoop currentRunLoop]; // 获取当前线程的runloop
    [NSRunLoop mainRunLoop];    // 获取主线程的runloop
    CFRunLoopGetCurrent();
    CFRunLoopGetMain();
}
//
//// 1
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    SEL temp = @selector(resolveThisMethodDynamically);
//    if (sel == temp) {
//        class_addMethod([self class], sel, (IMP)dynamicMethodIMP, "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
//// 2
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return  nil;
//}
//
//// 3
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//
//}
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//
//}
//// 4
//- (void)doesNotRecognizeSelector:(SEL)aSelector {
//
//}


@end

void resolveThisMethodDynamically(id self, SEL _cmd) {
    
}

