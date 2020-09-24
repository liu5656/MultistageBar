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
    func ss_setup(progress: CGFloat, backColor: UIColor, strokeColor: UIColor) {
        backgroundLayer = CAShapeLayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        backgroundLayer.path = path.cgPath
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = backColor.cgColor
        backgroundLayer.fillColor = nil
        backgroundLayer.lineCap = .round
        self.layer.addSublayer(backgroundLayer)
        
        progressLayer = CAShapeLayer()
        progressLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        progressLayer.path = path.cgPath
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeColor = strokeColor.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeEnd = progress
        progressLayer.lineCap = .round
        self.layer.addSublayer(progressLayer)
    }
    
    func ss_update(progress: CGFloat, animated: Bool = false, count: Float = 000, duration: CFTimeInterval = 1, autoreverse: Bool = false) {
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
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    var lineWidth: CGFloat = 2
}
