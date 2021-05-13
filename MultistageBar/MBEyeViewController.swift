//
//  MBEyeViewController.swift
//  MultistageBar
//
//  Created by x on 2021/5/12.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

// 参考:http://www.cocoachina.com/articles/15251
class MBEyeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
    }
    
    func setupAnimation() {
//        eyeFirstLightLayer.lineWidth = 0
//        eyeSecondLightLayer.lineWidth = 0
//        eyeballLayer.opacity = 0
//        bottomEyesocketLayer.strokeStart = 0.5
//        bottomEyesocketLayer.strokeEnd = 0.5
//        topEyesocketLayer.strokeStart = 0.5
//        topEyesocketLayer.strokeEnd = 0.5
        
        view.layer.addSublayer(eyeFirstLightLayer)
        view.layer.addSublayer(eyeSecondLightLayer)
        view.layer.addSublayer(eyeballLayer)
        view.layer.addSublayer(topEyesocketLayer)
        view.layer.addSublayer(bottomEyesocketLayer)
        
//        eyeFirstLightLayer.lineWidth = 1
//        eyeSecondLightLayer.lineWidth = 1
//        eyeballLayer.opacity = 0
//        bottomEyesocketLayer.strokeStart = 1
//        bottomEyesocketLayer.strokeEnd = 1
//        topEyesocketLayer.strokeStart = 1
//        topEyesocketLayer.strokeEnd = 1
    }
    private func angle(_ value: CGFloat) -> CGFloat {
        return (value / 180) * CGFloat(Double.pi)
    }
    
    let center = CGPoint.init(x: Screen.width * 0.5, y: Screen.height * 0.5)
    let radius = Screen.width * 0.5
    let halfHeight = Screen.height * 0.5
    lazy var eyeFirstLightLayer: CAShapeLayer = {
        let path = UIBezierPath.init(arcCenter: center,
                                     radius: radius,
                                     startAngle: angle(230),
                                     endAngle: angle(265),
                                     clockwise: true)
        let lay = CAShapeLayer.init()
        lay.borderColor = UIColor.black.cgColor
        lay.lineWidth = 5
        lay.path = path.cgPath
        lay.fillColor = UIColor.clear.cgColor
        lay.strokeColor = UIColor.white.cgColor
        return lay
    }()
    lazy var eyeSecondLightLayer: CAShapeLayer = {
        let path = UIBezierPath.init(arcCenter: center,
                                     radius: Screen.width * 0.2,
                                     startAngle: angle(211),
                                     endAngle: angle(220),
                                     clockwise: true)
        let lay = CAShapeLayer.init()
        lay.borderColor = UIColor.black.cgColor
        lay.lineWidth = 5
        lay.path = path.cgPath
        lay.fillColor = UIColor.clear.cgColor
        lay.strokeColor = UIColor.white.cgColor
        return lay
    }()
    lazy var eyeballLayer: CAShapeLayer = {
        let path = UIBezierPath.init(arcCenter: center,
                                     radius: Screen.width * 0.3,
                                     startAngle: angle(0),
                                     endAngle: angle(360),
                                     clockwise: true)
        let lay = CAShapeLayer.init()
        lay.borderColor = UIColor.black.cgColor
        lay.lineWidth = 1
        lay.path = path.cgPath
        lay.fillColor = UIColor.clear.cgColor
        lay.strokeColor = UIColor.white.cgColor
//        lay.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        return lay
    }()
    lazy var topEyesocketLayer: CAShapeLayer = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: halfHeight))
        path.addQuadCurve(to: CGPoint.init(x: Screen.width, y: halfHeight),
                          controlPoint: CGPoint.init(x: radius, y: center.y - center.y - 20))
        
        let lay = CAShapeLayer.init()
        lay.borderColor = UIColor.black.cgColor
        lay.lineWidth = 1
        lay.path = path.cgPath
        lay.fillColor = UIColor.clear.cgColor
        lay.strokeColor = UIColor.white.cgColor
        return lay
    }()
    lazy var bottomEyesocketLayer: CAShapeLayer = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: halfHeight))
        path.addQuadCurve(to: CGPoint.init(x: Screen.width, y: halfHeight),
                          controlPoint: CGPoint.init(x: Screen.width * 0.5, y: center.y + center.y + 20))
        
        let lay = CAShapeLayer.init()
        lay.borderColor = UIColor.black.cgColor
        lay.lineWidth = 1
        lay.path = path.cgPath
        lay.fillColor = UIColor.clear.cgColor
        lay.strokeColor = UIColor.white.cgColor
        return lay
    }()

}
