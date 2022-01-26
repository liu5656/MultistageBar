//
//  InitialViewController.swift
//  MultistageBar
//
//  Created by x on 2020/4/30.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit


class InitialViewController: UIViewController {
    func insertDatasOnTop() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
            let temp = [
                (MBDistanceViewController.classForCoder(), "insert"),
                (MBDistanceViewController.classForCoder(), "insert"),
                (MBDistanceViewController.classForCoder(), "insert"),
                (MBDistanceViewController.classForCoder(), "insert"),
                (MBDistanceViewController.classForCoder(), "insert"),
                (MBDistanceViewController.classForCoder(), "insert"),
                (MBDistanceViewController.classForCoder(), "insert")
            ]
            self?.datas.insert(contentsOf: temp, at: 0)
            let tempHeight = temp.count * 44
            var indexs: [IndexPath] = []
            temp.enumerated().forEach { (model) in
                indexs.append(IndexPath.init(row: model.offset, section: 0))
            }
            DispatchQueue.main.async {
                self?.table.reloadData()
                self?.table.contentOffset = CGPoint.init(x: 0, y: tempHeight - 20)
                self?.table.endHeaderRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = table
        table.beginHeaderRefreshing()
        if #available(iOS 13, *) {
            datas.append((SignInAppleViewController.classForCoder(), "苹果登录"))
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let temp: Any = MBGLSLViewController.classForCoder()
//        if let vc = temp as? UIViewController.Type {
//            let mb = vc.init()
//            debugPrint(mb)
//        }
        
    }
    lazy var datas: [(Any, String)] = {
        var datas: [(Any, String)] = [
            (SnapshotViewController.classForCoder(), "截图"),
            (ThreadTestViewController.classForCoder(), "队列理解"),
            (SwizzleViewController.classForCoder(), "Swizzle测试"),
            (JSViewController.classForCoder(), "JS调用iOS异步返回,JS注入"),
            (HttpsViewController.classForCoder(), "HTTPS双向测试"),
            ("opengles", "OpenGL ES测试"),
            //        (MBGLSLViewController.classForCoder(), "OpenGL ES GLSL渲染"),
            //        (MBOpenGLViewController.classForCoder(), "OpenGL ES GLKit"),
            (MBPlayerViewController.classForCoder(), "AVPlayer播放"),
            (MBDynamicViewController.classForCoder(), "UIDynamic物理仿真器使用"),
            (MBOrderMenuTestController.classForCoder(), "左右菜单联动,仿UIScrollView效果"),
            (SwipeToLikeViewController.classForCoder(), "左滑不喜欢,右滑喜欢"),
            (MBSortViewController.classForCoder(), "各种排序算法"),
            (MBCodecTestViewController.classForCoder(), "视频编解码"),
            (MBDistanceViewController.classForCoder(), "经纬度距离计算"),
            (MBCornerMarkViewController.classForCoder(), "带角标的菜单"),
            (MBHeaderViewController.classForCoder(), "带顶部的一级菜单"),
            (MBMultistageViewController.classForCoder(), "多级菜单"),
            (JSONViewController.classForCoder(), "json<->模型"),
            (MBEyeViewController.classForCoder(), "CAShapeLayer画眼睛"),
            (ProgressViewController.classForCoder(), "进度条"),
            (AlbumTestViewController.classForCoder(), "获取相册图片/裁剪"),
            (SwipeTestViewController.classForCoder(), "swipe"),
            (MBCornerImageViewController.classForCoder(), "图片通过像素裁剪"),
            (MBLocationViewController.classForCoder(), "获取定位信息"),
            (MBRetryViewController.classForCoder(), "失败重试策略"),
            (MBRetrieveImageSizeViewController.classForCoder(), "只获取网上图片尺寸"),
            (MBRefreshTestViewController.classForCoder(), "刷新控件和uicollectionview.isPagingEnabled的测试"),
            (MBHashTestViewController.classForCoder(), "SHA1/SHA256/SHA512/DES/AES/RSA"),
            (WrapTableViewController.classForCoder(), "封装tableView"),
            (MBTimerViewController.classForCoder(), "倒计时测试"),
            (IDFAViewController.classForCoder(), "IDFA授权")
        ]
        
        if #available(iOS 13, *) {
            datas.append((ShakeFeedbackViewController.classForCoder(), "震动反馈"))
            datas.append((AsyncViewController.classForCoder(), "swift5.5异步编程"))
            datas.append((APMViewController.classForCoder(), "APM"))
        } else {
            // Fallback on earlier versions
        }
        
        
        return datas
        
    }()
    
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))
//        tab.contentInset = UIEdgeInsets.init(top: -10, left: 0, bottom: 0, right: 10)
        tab.delegate = self
        tab.dataSource = self
        tab.tableFooterView = UIView.init()
        view.addSubview(tab)
        tab.refreshHeader {
            self.insertDatasOnTop()
        }
//        tab.refreshFooter {
//            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
//                DispatchQueue.main.async {
//                    tab.endFooterRefreshing(hasMoreData: true)
//                }
//            }
//        }
        return tab
    }()
    
    
}

extension InitialViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = datas[indexPath.row].1
        return cell!
    }
}

extension InitialViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let type = datas[indexPath.row].0 as? UIViewController.Type {
            let vc: UIViewController
            if WrapTableViewController.self == type {
                vc = WrapTableViewController.init(request: TempRequest())
            }else{
                vc = type.init()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else if let name = datas[indexPath.row].0 as? String { // storyboard加载
            let sb = UIStoryboard.init(name: name, bundle: Bundle.main)
            if let vc = sb.instantiateInitialViewController() {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        

        
        
//        guard let type = datas[indexPath.row].0 as? UIViewController.Type else {return}
//        let vc: UIViewController
////        if WrapTableViewController<TempModel>.self == type {
//            if WrapTableViewController.self == type {
////                vc = WrapTableViewController<TempModel>.init(request: TempRequest())
//            vc = WrapTableViewController.init(request: TempRequest())
//        }else{
//            vc = type.init()
//        }
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
