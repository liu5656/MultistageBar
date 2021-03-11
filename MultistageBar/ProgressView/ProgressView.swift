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
    func ss_setup(progress: CGFloat, background: CGFloat) {
        backgroundLayer.path = path.cgPath
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = backColor.cgColor
        backgroundLayer.strokeEnd = background
        
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

class SliderProgress: ProgressView {
    
    override func ss_setup(progress: CGFloat, background: CGFloat) {
        super.ss_setup(progress: progress, background: background)
        startCircle.center = CGPoint.init(x: bounds.width * progress, y: startCircle.center.y)
    }
    
    @objc func slider(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else {return}
        
        let centerX = min(max(pan.location(in: self).x, 0), bounds.width)
        view.center = CGPoint.init(x: centerX, y: view.center.y)
        
        if pan.state == .ended || pan.state == .cancelled {
            let ratio = centerX / bounds.width
            progressLayer.strokeEnd = ratio
            sliderCallback?(ratio)
        }
    }
    var sliderCallback: ((CGFloat) -> Void)?
    private lazy var startCircle: UIView = {
        let temp = UIView.init(frame: CGRect.init(x: -10, y: (bounds.height - 20) * 0.5, width: 20, height: 20))
        temp.layer.cornerRadius = 10
        temp.backgroundColor = UIColor.red
        addSubview(temp)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(slider(pan:)))
        temp.addGestureRecognizer(pan)
        return temp
    }()
}

class SpanProgress: ProgressView {
    
    override func ss_setup(progress: CGFloat, background: CGFloat) {
        super.ss_setup(progress: progress, background: background)
        _ = startCircle
        _ = endCircle
        progressLayer.strokeStart = (floorValue - minValue) / (maxVlue - minValue)
        progressLayer.strokeEnd = (ceilValue - minValue) / (maxVlue - minValue)
    }
    
    var isSpan: Bool = false
    var spanCallback: ((CGFloat, CGFloat) -> Void)?
    var maxVlue: CGFloat = 1    // 最大值
    var minValue: CGFloat = 0   // 最小值
    
    var ceilValue: CGFloat = 0  // 上限值
    var floorValue: CGFloat = 0 // 下限值
    
    var startCircleBackColor: UIColor = UIColor.gray
    var endCircleBackColor: UIColor = UIColor.black
    
    private lazy var startCircle: UIView = {
        let temp = UIView.init(frame: CGRect.init(x: bounds.width * (floorValue - minValue) / (maxVlue - minValue) - 10, y: (bounds.height - 20) * 0.5, width: 20, height: 20))
        temp.layer.cornerRadius = 10
        temp.backgroundColor = startCircleBackColor
        addSubview(temp)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(slider(pan:)))
        temp.addGestureRecognizer(pan)
        return temp
    }()
    private lazy var endCircle: UIView = {
        let temp = UIView.init(frame: CGRect.init(x: bounds.width * (ceilValue - minValue) / (maxVlue - minValue) - 10, y: (bounds.height - 20) * 0.5, width: 20, height: 20))
        temp.layer.cornerRadius = 10
        temp.backgroundColor = endCircleBackColor
        addSubview(temp)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(slider(pan:)))
        temp.addGestureRecognizer(pan)
        return temp
    }()
    @objc func slider(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else {return}
        
        let centerX: CGFloat
        if view == startCircle {
            centerX = min(max(pan.location(in: self).x, 0), endCircle.frame.minX - 20)
        }else{
            centerX = min(max(pan.location(in: self).x, startCircle.frame.maxX + 20), bounds.width)
        }
        
        view.center = CGPoint.init(x: centerX, y: view.center.y)
        
        let ratio = centerX / bounds.width
        let value = ratio * (maxVlue - minValue)
        
        if view == endCircle {
            progressLayer.strokeEnd = ratio
            ceilValue = value + minValue
        }else{
            progressLayer.strokeStart = ratio
            floorValue = value + minValue
        }
        spanCallback?(floorValue, ceilValue)
    }
}
