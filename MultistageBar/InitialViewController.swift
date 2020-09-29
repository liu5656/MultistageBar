//
//  InitialViewController.swift
//  MultistageBar
//
//  Created by x on 2020/4/30.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

//
//enum VCStyle: String, CaseIterable {
//    static let allValues = VCStyle.allCases
//    case onlyTitle = "DDLOnlyTitleViewController"
//    case header = "DDLHeaderViewController"
//    case multistage = "DDLMultistageViewController"
//    case signInApple = "SignInAppleViewController"
//    case jsonMap = "JSONViewController"
//    case progress = "ProgressViewController"
//    case alum = "AlbumTestViewController"
//    case swipe = "SwipeTestViewController"
//}


class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = table
        table.beginHeaderRefreshing()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    let datas: [(AnyClass, String)] = [
        (DDLOnlyTitleViewController.classForCoder(), "只有一级菜单"),
        (DDLHeaderViewController.classForCoder(), "带顶部的一级菜单"),
        (DDLMultistageViewController.classForCoder(), "多级菜单"),
        (SignInAppleViewController.classForCoder(), "苹果登录"),
        (JSONViewController.classForCoder(), "json<->模型"),
        (ProgressViewController.classForCoder(), "进度条"),
        (AlbumTestViewController.classForCoder(), "获取相册图片/裁剪"),
        (SwipeTestViewController.classForCoder(), "swipe")
    ]
    
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))
//        tab.contentInset = UIEdgeInsets.init(top: -10, left: 0, bottom: 0, right: 10)
        tab.delegate = self
        tab.dataSource = self
        tab.tableFooterView = UIView.init()
        view.addSubview(tab)
        tab.refreshHeader {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                DispatchQueue.main.async {
                    tab.endHeaderRefreshing()
                }
            }
        }
        tab.refreshFooter {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                DispatchQueue.main.async {
                    tab.endFooterRefreshing(hasMoreData: true)
                }
            }
        }
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
        let vc = type.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
