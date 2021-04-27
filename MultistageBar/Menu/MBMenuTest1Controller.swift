//
//  MBMenuTest1Controller.swift
//  MultistageBar
//
//  Created by x on 2021/4/25.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuTest1Controller: MBViewController, MBLinkageTableDelegate {

    // MBLinkageTableDelegate
    func mb_headerDidScroll(offsetY: CGFloat) {
        let gap = header.frame.height - bar.frame.height
        guard offsetY >= 0 else {
            return
        }
        bar.alpha = offsetY / gap
//        MBLog(offsetY)
    }
    
    // life crycle
    override func viewDidLoad() {
        super.viewDidLoad()
        menu.datas = datas
    }
    
    // lazy
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
    
    lazy var bar: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 0, y: header.frame.height - 48, width: header.frame.width, height: 48))
        vie.backgroundColor = UIColor.red
        vie.alpha = 0
        header.addSubview(vie)
        return vie
    }()
    lazy var header: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 400))
        let temp = UISwitch.init(frame: CGRect.init(x: 0, y: vie.frame.height - 30, width: 100, height: 30))
        vie.addSubview(temp)
        return vie
    }()
    
    lazy var menu: MBLinkageTable = {
        let temp = MBLinkageTable.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
        temp.topOffset = bar.frame.height
        temp.add(header: header)
        temp.headerDelegate = self
        view.addSubview(temp)
        return temp
    }()
}

