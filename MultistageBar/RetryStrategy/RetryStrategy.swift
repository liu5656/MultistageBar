//
//  RetryStrategy.swift
//  MultistageBar
//
//  Created by x on 2020/10/12.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation

class RetryStrategy: NSObject {
    var times: UInt8 = 5
    var delay = 0
    private var waiting = false
    private var callback: (()->Void)?
    
    @objc func tryCall(callback: @escaping ()->Void) {
        if waiting == false && delay < times {
            self.callback = callback
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            perform(#selector(immediatelyCall), with: nil, afterDelay: (TimeInterval(delay)))
            waiting = true
            delay += 1
        }else{
            self.callback = nil
        }
    }
    @objc func immediatelyCall() {
        waiting = false
        guard let callback = callback else {return}
        callback()
    }
    @objc func resetPolicy() {
        delay = 1
        waiting = false
    }
    func repeatAction() {
        guard let callback = callback else {return}
        self.tryCall(callback: callback)
    }
    deinit {
        MBLog("")
    }
}
