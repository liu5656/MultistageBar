//
//  MBRetryViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/12.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBRetryViewController: MBViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let temp = RetryStrategy.init()
            temp.times = 2
            temp.tryCall {
                MBLog("\(Thread.current)")
                temp.repeatAction()
                self.date = Date.init()
            }

        GlobalThread {
            /*
             Invokes a method of the receiver on the current thread using the default mode after a delay.
             
             This method sets up a timer to perform the aSelector message on the current thread’s run loop.
             The timer is configured to run in the default mode (NSDefaultRunLoopMode).
             When the timer fires, the thread attempts to dequeue the message from the run loop and perform the selector.
             It succeeds if the run loop is running and in the default mode; otherwise, the timer waits until the run loop is in the default mode.
             
             */
            self.perform(#selector(self.mb_test), with: nil, afterDelay: 1)
            MBLog("global after perform")
        }
        
        
    }
    
    @objc func mb_test() {
        MBLog("start")
    }
    
    var date: Date?
}
