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
        guard let num = delegate?.numberOfCard(), num != dataCount else {
            return
        }
        dataCount = num
        guard visiblePool.count == 0 else {
            return
        }
        for index in 0...visibleMaxNum {
            // 先放底部的内容,再上上面的内推
            guard let temp = delegate?.cellForCard(index: vanished + (visibleMaxNum - index), container: self) else {
                return
            }
            temp.isHidden = false
            temp.alpha = 1
            temp.transform = CGAffineTransform.identity
            visiblePool.insert(temp, at: 0)
            bringSubviewToFront(temp)
        }
    }
    func retrieveItemFromReusablePool(index: Int) -> MBDragingItem {
        let result: MBDragingItem
        if let item = reusablePool.first {
            reusablePool.removeFirst()
            item.isHidden = false
            item.alpha = 1
            item.transform = CGAffineTransform.identity
            if let first = visiblePool.first {
                bringSubviewToFront(first)
            }
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
            let pan = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
            temp.addGestureRecognizer(pan)
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tap(_:)))
            temp.addGestureRecognizer(tap)
        }
        return result
    }
    @objc func tap(_ tap: UITapGestureRecognizer) {
        delegate?.didSelected(index: vanished)
    }
    @objc func pan(_ pan: UIPanGestureRecognizer) {
        guard let view = pan.view else {
            return
        }
        let loc = pan.translation(in: view)
        let angle = loc.x / halfWidth * CGFloat(Double.pi / 50)
        let ratio = min(CGFloat(abs(Int32(loc.x))) / threshold, 1)
        switch pan.state {
        case .changed:          // 旋转和移动
            let translation = CGAffineTransform.init(translationX: loc.x, y: loc.y)
            let rotate = CGAffineTransform.init(rotationAngle: angle)
            view.transform = translation.concatenating(rotate)
        case .ended, .cancelled:
            if ratio >= 1 {     // 移除
                let offScreen = loc.x > 0 ? (loc.x + bounds.width) : (loc.x - bounds.width)
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0.2
                    view.transform = CGAffineTransform.init(translationX: offScreen, y: loc.y + 120)
                } completion: { [weak self] (_) in
                    self?.recycle(direction: loc.x > 0 ? .right : .left)
                }
            }else{              // 恢复
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                    view.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        default:
            break
        }
    }
    private func recycle(direction: SlidingDirection) {
        // 1.从界面上删除
        let item = visiblePool.removeFirst()
        item.isHidden = true
        reusablePool.append(item)
        // 2.通知代理划走的索引
        delegate?.didSlippedOut(index: vanished, direction: direction)
        vanished += 1
        // 3.检查是否还有数据
        guard (dataCount - 1) > vanished else {
            emptyV.isHidden = false
            return
        }
        emptyV.isHidden = true
        // 4.有数据就获取容器,然后展示
        guard let next = delegate?.cellForCard(index: vanished + 1, container: self) else {
            return
        }
        visiblePool.append(next)
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        preparePreview()
    }
    deinit {
        print("mbdragingcontainer deinit")
    }
    
    let visibleMaxNum = 1
    var vanished: Int = 0
    let halfWidth = Screen.width * 0.5
    let threshold = Screen.width * 0.25             // 切换阀值
    var dataCount: Int = 0
    var visiblePool: [MBDragingItem] = []           // 存储逻辑,最顶层的视图在最前面
    var reusablePool: [MBDragingItem] = []
    weak var delegate: MBDragingCardDelegate?
    lazy var emptyV: UIView = {
        let temp = UIView.init(frame: bounds)
        temp.backgroundColor = UIColor.black
        temp.isHidden = true
        addSubview(temp)
        
        let img = UIImageView.init(frame: CGRect.init(x: (temp.frame.width - 60) * 0.5, y: 100, width: 60, height: 60))
        img.image = UIImage.init(named: "empty")
        temp.addSubview(img)
        
        let tip = UILabel.init(frame: CGRect.init(x: img.frame.midX - 150, y: img.frame.maxY + 8, width: 300, height: 20))
        tip.textColor = UIColor.white
        tip.backgroundColor = UIColor.black
        tip.text = "已经没有更多数据咯"
        tip.textAlignment = .center
        temp.addSubview(tip)
        
        return temp
    }()
}
