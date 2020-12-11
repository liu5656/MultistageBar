//
//  MBTimer.swift
//  MultistageBar
//
//  Created by x on 2020/12/2.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

// 切换到后台后,定时器不会再执行回调,
class MBTimer {
    
    private enum TimeState {
        case suspend
        case resume
    }
    
    open class func timer(timeInterval: DispatchTimeInterval, count: Int = 1, queue: DispatchQueue = DispatchQueue.main, callback: @escaping (Int) -> Void) -> MBTimer { // 0无限,>0指定具体次数
        let timer = MBTimer.init()
        timer.mb_sched(timeInteral: timeInterval, count: count, queue: queue, callback: callback)
        return timer
    }
    
    private func mb_sched(timeInteral ti: DispatchTimeInterval, count: Int, queue: DispatchQueue = DispatchQueue.main, callback: @escaping (Int) -> Void) {
        originalCountdown = count
        countdown = count
        source = DispatchSource.makeTimerSource(flags: [], queue: queue)
        // DispatchWallTime：An absolute point in time according to the wall clock, with microsecond precision.
        // DispatchTime：A point in time relative to the default clock, with nanosecond precision.
        let deadline = DispatchWallTime.now() + ti
        if count == 1  {
            source?.schedule(wallDeadline: deadline)
        }else{
            source?.schedule(wallDeadline: deadline, repeating: ti, leeway: .milliseconds(10))
        }
        source?.setEventHandler { [unowned self] in
            if count == 0 {
                self.countdown += 1
            }else{
                self.countdown -= 1
            }
            if self.countdown == 0, count > 0 {
                self.mb_suspend()
            }
            callback(self.countdown)
        }
    }
    
    func mb_invalid() {
        if state == .suspend {
            self.mb_resume()
        }
        if source?.isCancelled == false {
            source?.cancel()
        }
        source = nil
    }
    
    func mb_updateOriginalCountdown(count: Int = 0) {
        originalCountdown = count
        countdown = originalCountdown
    }
    
    func mb_resume(refresh: Bool = false) {
        guard state != .resume else {return}
        lock.lock()
        defer {
            lock.unlock()
        }
        state = .resume
        if refresh {
            countdown = originalCountdown
        }
        source?.resume()
    }
    func mb_suspend(){
        guard state != .suspend else {return}
        lock.lock()
        defer {
            lock.unlock()
        }
        state = .suspend
        source?.suspend()
    }
    
    private var countdown: Int = 1
    private var originalCountdown: Int = 1
    private var source: DispatchSourceTimer?
    private var state: TimeState = .suspend
    private var lock = NSLock.init()
    
    deinit {
        mb_invalid()
    }
}



