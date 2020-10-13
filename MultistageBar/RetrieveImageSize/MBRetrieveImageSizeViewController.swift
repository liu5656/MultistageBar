//
//  MBRetrieveImageSizeViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/13.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBRetrieveImageSizeViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlStr = [
            "http://n.sinaimg.cn/photo/transform/700/w1000h500/20200923/008b-izmihnu6505409.jpg",
            "http://n.sinaimg.cn/photo/transform/700/w1000h500/20200907/eac7-iytwsca6488747.jpg",
            "http://n.sinaimg.cn/tech/5_img/upload/3911b535/106/w1024h682/20201009/6b39-kaaxtfp0044339.jpg",
            "http://n.sinaimg.cn/tech/5_img/upload/3911b535/192/w1024h768/20201009/6ed9-kaaxtfp0044329.jpg"
        ]
        let result = urlStr.map({URL.init(string: $0)!})
        result.forEach { (url) in
            MBLog(ImageRetrieve.size(url: url))
        }
    }
}
