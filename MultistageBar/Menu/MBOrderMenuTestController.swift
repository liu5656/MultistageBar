//
//  MBOrderMenuTestController.swift
//  MultistageBar
//
//  Created by x on 2021/2/23.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBOrderMenuTestController: MBViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       _ = table
    }
    
    var datas: [(String, AnyClass)] = [
        ("一次性展示全部分区", MBMenuTest1Controller.classForCoder()),
        ("一次显示一个分区", MBMenuTest2Controller.classForCoder()),
        ("分类菜单", MBMenuTest3ViewController.classForCoder()),
        ("仿美团点餐分类菜单", MBMenuTest4ViewController.classForCoder())
    ]
    
    let identify = "cellIdentify"
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identify)
        tab.delegate = self
        tab.dataSource = self
        view.addSubview(tab)
        return tab
    }()
}

extension MBOrderMenuTestController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let temp = datas[indexPath.row].1 as? UIViewController.Type else {return}
        let vc = temp.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        cell.textLabel?.text = datas[indexPath.row].0
        return cell
    }
}
