//
//  MBMenuTest2Controller.swift
//  MultistageBar
//
//  Created by x on 2021/4/25.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuTest2Controller: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = left
        _ = right
    }
    
    let identify = "cellIdentify"
    
    lazy var header: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 200))
        vie.backgroundColor = UIColor.red
        
        let swi = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 40))
        vie.addSubview(swi)
        
        return vie
    }()
    lazy var left: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: Screen.height - Screen.fakeNavBarHeight))
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identify)
        tab.delegate = self
        tab.dataSource = self
        tab.tableHeaderView = header
        view.addSubview(tab)
        return tab
    }()
    lazy var right: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: left.frame.maxX, y: header.frame.maxY, width: Screen.width - 200, height: Screen.height - Screen.fakeNavBarHeight))
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identify)
        tab.delegate = self
        tab.dataSource = self
//        tab.tableHeaderView = header
        view.addSubview(tab)
        return tab
    }()
}


extension MBMenuTest2Controller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let temp = datas[indexPath.row].1 as? UIViewController.Type else {return}
//        let vc = temp.init()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        cell.textLabel?.text = "index: \(indexPath.row)"
        return cell
    }
}
