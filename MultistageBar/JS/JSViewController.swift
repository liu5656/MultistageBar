//
//  JSViewController.swift
//  MultistageBar
//
//  Created by x on 2021/3/22.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit


class JSViewController: MBViewController, MBWebViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let path:String! = Bundle.main.path(forResource: "index", ofType: "html")
        web.load(URLRequest(url: URL(fileURLWithPath: path)))
    }
    
    // MBWebviewDelegate
    func mb_handle(command: MBWebView.ScriptName, info: [String : Any]?, callback: (([String : Any]) -> Void)?) {
        switch command {
        case .login:
            MBLog("js调用iOS成功: params: \(info)")
            callback?(["jj": "kk"])
        }
    }
    
    // lazy
    lazy var web: MBWebView = {
        let temp = MBWebView.init()
        temp.delegate = self
        temp.frame = view.bounds
        view.addSubview(temp)
        return temp
    }()
    
}
