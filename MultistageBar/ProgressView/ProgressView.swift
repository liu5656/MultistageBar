//
//  ProgressView.swift
//  MultistageBar
//
//  Created by x on 2020/9/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
/*
 参考如下
 https://www.octobot.io/blog/2016-12-28-custom-progress-indicators-in-swift/
 https://www.jianshu.com/p/492a151ba25b
 https://github.com/zhanming0601/AnimationCheckButton/blob/master/AnimationCheckButton/checkButton.m
 */

class ProgressView: UIView {
    init(frame: CGRect, path: UIBezierPath, lineWidth: CGFloat = 2) {
        super.init(frame: frame)
        self.lineWidth = lineWidth
        self.path = path
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func ss_setup(progress: CGFloat) {
        backgroundLayer.path = path.cgPath
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = backColor.cgColor
        
        progressLayer.path = path.cgPath
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeColor = strokeColor.cgColor
        progressLayer.strokeEnd = progress
    }
    
    func ss_update(progress: CGFloat, animated: Bool = false, count: Float = 1, duration: CFTimeInterval = 1, autoreverse: Bool = false) {
        if animated {
            let animation = CABasicAnimation.init(keyPath: "strokeEnd")
            animation.repeatCount = count
            animation.duration = duration
            animation.fromValue = progressLayer.strokeStart
            animation.toValue = progress
            animation.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            animation.autoreverses = autoreverse
            animation.isRemovedOnCompletion = false
            progressLayer.add(animation, forKey: "strokeEnd")
        }
        if count == 1 {
            self.progressLayer.strokeEnd = progress
        }
    }
    private var path: UIBezierPath!
    var lineWidth: CGFloat = 2
    var backColor: UIColor = UIColor.lightGray
    var strokeColor: UIColor = UIColor.gray
    
    lazy var backgroundLayer: CAShapeLayer = {
        let temp = CAShapeLayer.init()
        temp.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        temp.lineWidth = lineWidth
        temp.fillColor = nil
        temp.lineCap = .round
        self.layer.addSublayer(temp)
        return temp
    }()
    lazy var progressLayer: CAShapeLayer = {
        let temp = CAShapeLayer.init()
        temp.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        temp.lineWidth = lineWidth
        temp.fillColor = nil
        temp.lineCap = .round
        self.layer.addSublayer(temp)
        return temp
    }()
}
