//
//  MBDynamicViewController.swift
//  MultistageBar
//
//  Created by x on 2021/5/13.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBDynamicViewController: MBViewController {
    
    var caterpillar: [UIView] = []
    func createView() {
        (0...8).forEach { (index) in
            let x = index * 30 + 60
            let y = Int(Screen.height - Screen.fakeNavBarHeight - 80)
            let width = 8 == index ? 50 : 30
            let temp = UIView.init(frame: CGRect.init(x: x, y: y - width / 2, width: width, height: width))
            let r = CGFloat(arc4random() % 255) / 255
            let g = CGFloat(arc4random() % 255) / 255
            let b = CGFloat(arc4random() % 255) / 255
            temp.backgroundColor = UIColor.init(red: r, green: g, blue: b, alpha: 1)
            temp.layer.cornerRadius = temp.frame.width * 0.5
            view.addSubview(temp)
            caterpillar.append(temp)
            // 添加重力行为
            let gravity = UIGravityBehavior.init()
            gravity.gravityDirection = CGVector.init(dx: 0, dy: 1)
            animator.addBehavior(gravity)
        }
        (0...7).forEach { (index) in
            // 添加吸附行为
            let attach = UIAttachmentBehavior.init(item: caterpillar[index], attachedTo: caterpillar[index + 1])
            animator.addBehavior(attach)
        }
        
        // 添加碰撞
        let coll = UICollisionBehavior.init(items: caterpillar)
        coll.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(coll)
    }
    @objc func gesture(pan: UIPanGestureRecognizer) {
        let point = pan.location(in: view)
        switch pan.state {
        case .began:
            attach = UIAttachmentBehavior.init(item: caterpillar.last!, attachedToAnchor: point)
            animator.addBehavior(attach!)
        case .changed:
            attach?.anchorPoint = point
        case .ended:
            animator.removeBehavior(attach!)
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = redV
        _ = blueV
        _ = greenV
        createView()
        _ = pan
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: view) else {
            return
        }
    }
    lazy var pan: UIPanGestureRecognizer = {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(gesture(pan:)))
        view.addGestureRecognizer(ges)
        return ges
    }()
    
    
    lazy var animator: UIDynamicAnimator = {
        let ani = UIDynamicAnimator.init(referenceView: view)
        ani.delegate = self
        return ani
    }()
    lazy var gravity: UIGravityBehavior = {
        let beh = UIGravityBehavior.init()
        beh.magnitude = 3
        beh.addItem(redV)
        beh.addItem(blueV)
//        beh.addItem(greenV)
        return beh
    }()
    lazy var collision: UICollisionBehavior = {
        let boundary = UIBezierPath.init(rect: view.bounds)
        
        let beh = UICollisionBehavior.init(items: [redV, blueV, greenV])
        beh.collisionMode = UICollisionBehavior.Mode.everything
        beh.addBoundary(withIdentifier: "identify" as NSCopying, for: boundary)
        return beh
    }()
    var attach: UIAttachmentBehavior?
    
    lazy var redV: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 30, y: 0, width: 150, height: 150))
        vie.backgroundColor = UIColor.red
        vie.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / 4))
        view.addSubview(vie)
        return vie
    }()
    lazy var blueV: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 30, y: 250, width: 100, height: 100))
        vie.backgroundColor = UIColor.blue
        view.addSubview(vie)
        return vie
    }()
    lazy var greenV: UIView = {
        let vie = UIView.init(frame: CGRect.init(x: 100, y: 160, width: 300, height: 30))
        vie.backgroundColor = UIColor.green
        vie.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / -8))
        view.addSubview(vie)
        return vie
    }()
    
}

extension MBDynamicViewController: UIDynamicAnimatorDelegate {
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        MBLog("")
    }
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        MBLog("")
//        animator.removeAllBehaviors()
    }
}
