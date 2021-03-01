//
//  MBDragingContainer.swift
//  MultistageBar
//
//  Created by x on 2021/2/5.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

protocol MBDragingCardDelegate: class {
    func numberOfCard() -> Int
    func cellForCard(index: Int, container: MBDragingContainer) -> MBDragingItem
    func didSlippedOut(index: Int, direction: MBDragingContainer.SlidingDirection)
    func didSelected(index: Int)
}

class MBDragingContainer: UIView {
    
    enum SlidingDirection {
        case left
        case right
    }
    func autoDraging(direction: SlidingDirection) {
        guard let item = visiblePool.first  else {
            return
        }
        let translation = CGAffineTransform.init(translationX: direction == .left ? -bounds.width : bounds.width, y: 200)
        let ratio = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / 50))
        UIView.animate(withDuration: 0.3) {
            item.alpha = 0.5
            item.transform = translation.concatenating(ratio)
        } completion: { [weak self] (_) in
            self?.recycle(direction: direction)
        }
    }
    func preparePreview() {
        guard let num = delegate?.numberOfCard(), num > 0 else {
            return
        }
        dataCount = num
        for index in 0...visibleMaxNum {
            // 先放底部的内容,再上上面的内推
            guard let temp = delegate?.cellForCard(index: visibleMaxNum - index, container: self) else {
                return
            }
            let pan = UIPanGestureRecognizer.init(target: self, action: #selector(action(pan:)))
            temp.addGestureRecognizer(pan)
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tap(_:)))
            visiblePool.insert(temp, at: 0)
        }
    }
    func retrieveItemFromReusablePool(index: Int) -> MBDragingItem {
        let result: MBDragingItem
        if let item = reusablePool.first {
            reusablePool.removeFirst()
            item.isHidden = false
            bringSubviewToFront(visiblePool.first!)
            result = item
        }else{
            let temp = MBDragingItem.init()
            temp.backgroundColor = UIColor.white
            temp.frame = bounds
            if index > visibleMaxNum {
                insertSubview(temp, at: 0)
            }else{
                addSubview(temp)
            }
            addSubview(temp)
            result = temp
        }
        return result
    }
    @objc func tap(_ tap: UITapGestureRecognizer) {
        delegate?.didSelected(index: vanished)
    }
    @objc func action(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else {
            return
        }
        let loc = pan.translation(in: view)
        let angle = loc.x / halfWidth * CGFloat(Double.pi / 50)
        let ratio = min(CGFloat(abs(Int32(loc.x))) / threshold, 1)
        switch pan.state {
        case .changed:
            let translation = CGAffineTransform.init(translationX: loc.x, y: loc.y)
            let rotate = CGAffineTransform.init(rotationAngle: angle)
            view.transform = translation.concatenating(rotate)
        case .ended, .cancelled:
            if ratio >= 1, dataCount > vanished {  // 移除
                let offScreen = loc.x > 0 ? (loc.x + bounds.width) : (loc.x - bounds.width)
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0.2
                    view.transform = CGAffineTransform.init(translationX: offScreen, y: loc.y + 120)
                } completion: { [weak self] (_) in
                    self?.recycle(direction: loc.x > 0 ? .right : .left)
                }
            }else{          // 恢复
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
                    view.transform = CGAffineTransform.identity
                } completion: { [weak self] (_) in
//                    self?.adaptLowerView(ratio: ratio)
                }
            }
        default:
            break
        }
    }
    private func recycle(direction: SlidingDirection) {
        delegate?.didSlippedOut(index: vanished, direction: direction)
        vanished += 1
        
        let item = visiblePool.removeFirst()
        item.isHidden = true
        selected += 1
        reusablePool.append(item)
        
        guard let next = delegate?.cellForCard(index: selected, container: self) else {
            return
        }
        visiblePool.append(next)
        next.isHidden = false
        next.alpha = 1
        next.transform = CGAffineTransform.identity
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if visiblePool.count == 0 {
            preparePreview()
        }
    }
    deinit {
        print("mbdragingcontainer deinit")
    }
    
    let visibleMaxNum = 1
    private var selected: Int = 1
    var vanished: Int = 0
    let halfWidth = Screen.width * 0.5
    let threshold = Screen.width * 0.25     // 切换阀值
    var dataCount: Int = 0
    var visiblePool: [MBDragingItem] = []          // 存储逻辑,从上到下存储
    var reusablePool: [MBDragingItem] = []
    weak var delegate: MBDragingCardDelegate?
}
