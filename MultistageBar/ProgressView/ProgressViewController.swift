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
        spanV.spanCallback = { [unowned self] minv, maxv in
            minL.text = "\(Int(minv))"
            maxL.text = "\(Int(maxv))"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lineProgress.ss_update(progress: 0.5, animated: true)
        circleProgress.ss_update(progress: 1, animated: true, count: 2, duration: 3, autoreverse: true)
    }
    
    lazy var lineProgress: ProgressView = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 4))
        path.addLine(to: CGPoint.init(x: 310, y: 4))
        let temp = ProgressView.init(frame: CGRect.init(x: 10, y: 100, width: 310, height: 8), path: path, lineWidth: 8)
        temp.backColor = UIColor.red
        temp.strokeColor = UIColor.blue
        temp.ss_setup(progress: 0, background: 1)
        view.addSubview(temp)
        return temp
    }()
    
    lazy var circleProgress: ProgressView = {
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: 50, y: 50), radius: 50, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let temp = ProgressView.init(frame: CGRect.init(x: 60, y: 160, width: 100, height: 100), path: path)
        temp.backColor = UIColor.red
        temp.strokeColor = UIColor.blue
        temp.ss_setup(progress: 0, background: 1)
        view.addSubview(temp)
        return temp
    }()
    
    lazy var spanV: SpanProgress = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 4))
        path.addLine(to: CGPoint.init(x: 250, y: 4))
        let temp = SpanProgress.init(frame: CGRect.init(x: 60, y: 300, width: 250, height: 8), path: path, lineWidth: 8)
        
        temp.maxVlue = 220
        temp.minValue = 140
        
        temp.ceilValue = 200
        temp.floorValue = 160
        
        temp.startCircleBackColor = UIColor.black
        temp.endCircleBackColor = UIColor.gray
        
        temp.backColor = UIColor.red
        temp.strokeColor = UIColor.blue
        
        #warning("1.0 待优化")
        temp.ss_setup(progress: 0, background: 1)
        
        view.addSubview(temp)
        return temp
    }()
    lazy var minL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: spanV.frame.minX - 70, y: spanV.frame.midY - 8, width: 60, height: 16))
        lab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lab.textColor = UIColor.black
        lab.textAlignment = .right
        view.addSubview(lab)
        return lab
    }()
    lazy var maxL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: spanV.frame.maxX + 10, y: spanV.frame.midY - 8, width: 60, height: 16))
        lab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()

}
