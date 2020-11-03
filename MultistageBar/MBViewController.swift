//
//  MBViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/12.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
    }
    deinit {
        MBLog("")
    }
}
