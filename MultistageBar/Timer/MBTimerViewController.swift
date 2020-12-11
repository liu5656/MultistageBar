//
//  MBTimerViewController.swift
//  MultistageBar
//
//  Created by x on 2020/12/11.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBTimerViewController: MBViewController {
    @objc func mb_countdown(num: Int) {
        MBLog(num)
    }
    func mb_timerTest() {
        timer.mb_resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mb_timerTest()  // 定时器测试
        // Do any additional setup after loading the view.
    }
    lazy var timer: MBTimer = {
        let temp = MBTimer.timer(timeInterval: .seconds(1), count: 60) { (num) in
            self.mb_countdown(num: num)
        }
        return temp
    }()
}
