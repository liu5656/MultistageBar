//
//  SwipeToLikeViewController.swift
//  MultistageBar
//
//  Created by x on 2021/2/5.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class SwipeToLikeViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = swipe
    }
    lazy var swipe: MBDragingContainer = {
        let swp = MBDragingContainer.init()
        swp.frame = CGRect.init(x: 0, y: 0, width: Screen.width, height: 400)
        view.addSubview(swp)
        return swp
    }()
    deinit {
        MBLog("")
    }
}
