//
//  FPSMonitor.swift
//  MultistageBar
//
//  Created by x on 2022/1/10.
//  Copyright © 2022 x. All rights reserved.
//

import UIKit

public class FPSMonitor: NSObject {
    
    private var link: CADisplayLink?
    private var lastTime: TimeInterval = 0;
    private var count: UInt = 0
    
    @objc public func enableMonitor() {
        if link == nil {
            link = CADisplayLink.init(target: self, selector: #selector(fpsCalculate(link:)))
            link?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
//            link?.isPaused = false
        }else{
            link?.isPaused = false
        }
    }
    
    
    public func disableMonitor() {
        if link != nil {
            link?.isPaused = true
            lastTime = 0
            count = 0
        }
    }
    
    public func destoryMonitor() {
        disableMonitor()
        link?.invalidate()
        link = nil
    }
    
    @objc func fpsCalculate(link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        count += 1;
        let delta = link.timestamp - lastTime
        if delta > 1 {
            let fps = Double(count) / delta
            print("fps is \(fps + 0.5)")
            lastTime = link.timestamp
            count = 0
        }
    }

}
