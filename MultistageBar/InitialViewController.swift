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
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    var datas: [(AnyClass, String)] = [
        (JSViewController.classForCoder(), "JS调用iOS异步返回,JS注入"),
        (MBGLSLViewController.classForCoder(), "OpenGL ES GLSL渲染"),
        (MBOpenGLViewController.classForCoder(), "OpenGL ES GLKit"),
        (MBPlayerViewController.classForCoder(), "AVPlayer播放"),
        (MBOrderMenuTestController.classForCoder(), "左右菜单联动"),
        (SwipeToLikeViewController.classForCoder(), "左滑不喜欢,右滑喜欢"),
        (MBSortViewController.classForCoder(), "各种排序算法"),
        (MBCodecTestViewController.classForCoder(), "视频编解码"),
        (MBDistanceViewController.classForCoder(), "经纬度距离计算"),
        (MBCornerMarkViewController.classForCoder(), "带角标的菜单"),
        (MBHeaderViewController.classForCoder(), "带顶部的一级菜单"),
        (MBMultistageViewController.classForCoder(), "多级菜单"),
        (SignInAppleViewController.classForCoder(), "苹果登录"),
        (JSONViewController.classForCoder(), "json<->模型"),
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
        guard let type = datas[indexPath.row].0 as? UIViewController.Type else {return}
        let vc: UIViewController
//        if WrapTableViewController<TempModel>.self == type {
            if WrapTableViewController.self == type {
//                vc = WrapTableViewController<TempModel>.init(request: TempRequest())
            vc = WrapTableViewController.init(request: TempRequest())
        }else{
            vc = type.init()
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
