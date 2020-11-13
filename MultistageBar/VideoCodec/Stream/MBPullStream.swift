//
//  MBPullStream.swift
//  MultistageBar
//
//  Created by x on 2020/11/12.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import CRTMP

class MBPullStream: NSObject {
    init(url: String) {
        
    }
    
    func mb_prepare() {
        let result = stream.setupUrl("rtmp://127.0.0.1/live/SJyShoitP")
        print(result)
        stream.setBuffer(milliSeconds: 3600 * 1000)
        stream.connect()
    }
    func pullStream() {
    }
    
    lazy var stream: Rtmp = {
        let temp = Rtmp.init()
        return temp
    }()
}
