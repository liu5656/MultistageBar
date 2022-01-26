//
//  ShakeFeedbackViewController.swift
//  MultistageBar
//
//  Created by x on 2022/1/18.
//  Copyright © 2022 x. All rights reserved.
//

import UIKit

@available(iOS 13, *)
class ShakeFeedbackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func impact(_ sender: UIButton) {
        guard let style = MBFeedback.ImpactStyle.init(rawValue: sender.tag) else {
            return
        }
        MBFeedback.impact(style: style)
//        let arr = ["1", "2"]
//        print(arr[2])
    }
    
    @IBAction func selection(_ sender: UIButton) {
    }
    @IBAction func notification(_ sender: UIButton) {
        guard let style = MBFeedback.NotificationStyle.init(rawValue: sender.tag) else {
            return
        }
        MBFeedback.notification(style: style)
    }
}
