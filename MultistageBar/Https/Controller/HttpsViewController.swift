//
//  HttpsViewController.swift
//  MultistageBar
//
//  Created by x on 2021/6/8.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class HttpsViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        https://localhost:8080/product
        let url = "https://192.168.0.69:8443/product"
        net.request(url: url, method: "GET")
    }
    let net = MBNet.init()

}
