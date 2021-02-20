//
//  MBDragingContainer.swift
//  MultistageBar
//
//  Created by x on 2021/2/5.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

protocol MBDragingCardDelegate {
    func dragingCardTemplate() -> AnyClass
}

class MBDragingContainer: UIView {
    let visibleMaxNum = 1
    lazy var data: [Int] = {
        var temp: [Int] = []
        for ind in 0..<20 {
            temp.append(ind)
        }
        return temp
    }()
    private func preparePreview() {
        for index in 0...visibleMaxNum {       // 从下到上编号: 3(完全被盖住, 缩小4%, 下移8%).2(缩小4%, 下移8%).1(缩小2%, 下移4%).0(完全放大)
            let temp = retrieveItemFromReusablePool(index: visibleMaxNum - index)   // 先放底部的内容,再上上面的内推
//            let ratio = 0.02 * CGFloat((previewNum - index))
//            let translation = CGAffineTransform.init(translationX: 0, y: bounds.height * ratio * 2)
//            let scale = CGAffineTransform.init(scaleX: 1 - ratio, y: 1 - ratio)
//            temp.transform = translation.concatenating(scale)
            
            let pan = UIPanGestureRecognizer.init(target: self, action: #selector(action(pan:)))
            temp.addGestureRecognizer(pan)
            visiblePool.insert(temp, at: 0)
        }
    }
    private func retrieveItemFromReusablePool(index: Int) -> MBDragingItem {
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
        result.imgIV.image = UIImage.init(named: "\(data[index % 3])")
        return result
    }
    
    @objc func action(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else {
            return
        }
        let loc = pan.translation(in: view)
        let angle = loc.x / width * CGFloat(Double.pi / 50)
        let ratio = min(CGFloat(abs(Int32(loc.x))) / threshold, 1)
        switch pan.state {
        case .began:
            MBLog("begin")
        case .changed:
            let translation = CGAffineTransform.init(translationX: loc.x, y: loc.y)
            let rotate = CGAffineTransform.init(rotationAngle: angle)
            view.transform = translation.concatenating(rotate)
//            adaptLowerView(ratio: ratio)
        case .ended, .cancelled:
            if ratio >= 1 {  // 移除
                let offScreen = loc.x > 0 ? (loc.x + bounds.width) : (loc.x - bounds.width)
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0.2
                    view.transform = CGAffineTransform.init(translationX: offScreen, y: loc.y + 120)
                } completion: { [weak self] (_) in
                    self?.recycle()
                }
            }else{          // 恢复
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
                    view.transform = CGAffineTransform.identity
                } completion: { [weak self] (_) in
//                    self?.adaptLowerView(ratio: ratio)
                }
            }
        default:
            MBLog("")
        }
    }
//    private func adaptLowerView(ratio: CGFloat) {
//        if 0 < ratio, 1 != ratio {    // 最上面和最下面的除外,其余都放大
//            for index in 0...(visibleMaxNum - 1) {
//                let ratio = 0.02 * CGFloat((visibleMaxNum - index)) * (1 - ratio)
//                let translation = CGAffineTransform.init(translationX: 0, y: bounds.height * ratio * 2)
//                let scale = CGAffineTransform.init(scaleX: 1 - ratio, y: 1 - ratio)
//                visiblePool[index].transform = translation.concatenating(scale)
//            }
//        }else if 0 == ratio {
//
//        }
//        // 准备下一张
//        MBLog("ratio : \(ratio)")
//    }
    private func recycle() {
        let item = visiblePool.removeFirst()
        item.isHidden = true
        selected += 1
        reusablePool.append(item)
//        let ratio = CGFloat((visiblePool.count - 1)) * 0.02
//        let translation = CGAffineTransform.init(translationX: 0, y: item.frame.height * ratio * 2)
//        let scale = CGAffineTransform.init(scaleX: 1 - ratio, y: 1 - ratio)
        
        let next = retrieveItemFromReusablePool(index: selected)
        visiblePool.append(next)
        next.isHidden = false
        next.alpha = 1
        next.transform = CGAffineTransform.identity
        
        
//        next.transform = translation.concatenating(scale)
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if visiblePool.count == 0 {
            preparePreview()
        }
    }
    deinit {
        MBLog("")
    }
    var selected: Int = 1
    let width = Screen.width * 0.5
    let threshold = Screen.width * 0.25     // 切换阀值
    
    var datas: [MBDragingCardDelegate] = []
    var visiblePool: [MBDragingItem] = []          // 存储逻辑,从上到下存储
    var reusablePool: [MBDragingItem] = []
}
