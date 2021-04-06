//
//  ViewController.swift
//  Applet
//
//  Created by x on 2021/4/2.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let vc = MBSortViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        self.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }


}

