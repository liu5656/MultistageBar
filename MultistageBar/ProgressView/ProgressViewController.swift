//
//  ProgressViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        _ = lineProgress
        _ = circleProgress
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lineProgress.ss_update(progress: 0.5, animated: true)
        circleProgress.ss_update(progress: 1, animated: true, count: 2, duration: 3, autoreverse: true)
    }
    
    lazy var lineProgress: ProgressView = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 4))
        path.addLine(to: CGPoint.init(x: 300, y: 4))
        let temp = ProgressView.init(frame: CGRect.init(x: 10, y: 100, width: 310, height: 8), path: path)
        temp.ss_setup(progress: 0, backColor: UIColor.red, strokeColor: UIColor.blue)
        view.addSubview(temp)
        return temp
    }()
    
    lazy var circleProgress: ProgressView = {
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: 50, y: 50), radius: 50, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let temp = ProgressView.init(frame: CGRect.init(x: 60, y: 160, width: 100, height: 100), path: path)
        temp.ss_setup(progress: 0, backColor: UIColor.red, strokeColor: UIColor.blue)
        view.addSubview(temp)
        return temp
    }()

}
