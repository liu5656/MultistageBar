//
//  MBMenuTest1Controller.swift
//  MultistageBar
//
//  Created by x on 2021/4/25.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuTest1Controller: MBViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        _ = menu
//    }
//
//    lazy var header: UIView = {
//        let vie = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 200))
//        let temp = UISwitch.init(frame: CGRect.init(x: 0, y: vie.frame.height - 30, width: 100, height: 30))
//        vie.addSubview(temp)
//        return vie
//    }()
//
//    lazy var menu: MBOrderMenu = {
//        let temp = MBOrderMenu.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
//        temp.add(header: header)
//        view.addSubview(temp)
//        return temp
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        menu.datas = datas
    }
    
    lazy var datas: [MBLinkage] = {
        var res: [MBLinkage] = []
        for i in 1...20 {
            let part = MBLinkage.init()
            part.title = "left: \(i)"
            
            for j in (i * 10)..<(i * 10 + 10) {
                let ele = MBSubLinkage.init()
                ele.title = "\(j)"
                part.nest.append(ele)
            }
            res.append(part)
        }
        return res
    }()
    
    lazy var header: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 200))
        let temp = UISwitch.init(frame: CGRect.init(x: 0, y: vie.frame.height - 30, width: 100, height: 30))
        vie.addSubview(temp)
        return vie
    }()
    
    lazy var menu: MBLinkageTable = {
        let temp = MBLinkageTable.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
        temp.add(header: header)
        view.addSubview(temp)
        return temp
    }()
}

