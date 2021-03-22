//
//  JSViewController.swift
//  MultistageBar
//
//  Created by x on 2021/3/22.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit


class JSViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let path:String! = Bundle.main.path(forResource: "index", ofType: "html")
        web.load(URLRequest(url: URL(fileURLWithPath: path)))
    }
    
    lazy var web: MBWebView = {
        let temp = MBWebView.init()
        temp.frame = view.bounds
        view.addSubview(temp)
        return temp
    }()
}
