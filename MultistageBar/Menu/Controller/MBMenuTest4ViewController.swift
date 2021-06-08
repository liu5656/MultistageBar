//
//  MBMenuTest4ViewController.swift
//  MultistageBar
//
//  Created by x on 2021/5/7.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class LJDynamicItem: NSObject, UIDynamicItem {
    var center: CGPoint = .zero
    var bounds: CGRect {
        get{
            return CGRect.init(x: 0, y: 0, width: 1, height: 1)
        }
    }
    var transform: CGAffineTransform = CGAffineTransform.init()
}

class MBMenuTest4ViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = table
        _ = pan
        _ = animator
    }
    
    var dynamicItem = LJDynamicItem.init()
    var decelerationBehavior: UIDynamicItemBehavior?
    
    @objc func gesture(pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: table)
        switch pan.state {
        case .began:
            animator.removeAllBehaviors()
        case .changed:
            verticalHandler(detal: point.y, state: pan.state)
        case .ended:
            dynamicItem.center = CGPoint.zero
            let velocity = pan.velocity(in: table)
            let behavior = UIDynamicItemBehavior.init(items: [dynamicItem])
            behavior.addLinearVelocity(CGPoint.init(x: 0, y: velocity.y), for: dynamicItem)
            behavior.resistance = 5
            var lastCenY: CGFloat = 0
            behavior.action = { [unowned self] in
                let cenY = CGFloat(Int(dynamicItem.center.y))   // 避免后面出现很多小数的值
                let detal = cenY - lastCenY
                verticalHandler(detal: detal, state: .ended)
                lastCenY = cenY
            }
            animator.addBehavior(behavior)
            decelerationBehavior = behavior
        break
        default:
            break
        }
        pan.setTranslation(CGPoint.zero, in: view)
    }
    
    // detal > 0 向下滑动; detal < 0 向上滑动
    func verticalHandler(detal: CGFloat, state: UIGestureRecognizer.State) {
        if table.contentOffset.y < maxY {                                       // 未超出最大值,仅改变父容器的offset
            var offset = table.contentOffset.y - detal
            if offset < 0 {
                offset = table.contentOffset.y - detal * 0.5                    // 超过顶部范围,增加减速因子
                if state == .ended {
                    switchSpringBehavior(on: table, from: offset, to: 0)        // 松手时,切换仿真
                }
            }
            table.contentOffset = CGPoint.init(x: 0, y: offset)
//            table.isScrollEnabled = true
        }else{
//            table.isScrollEnabled = false
            var offset = max(0, footer.right.contentOffset.y - detal)                               // 子列表offset.y总是大于等于0
            if offset + footer.right.bounds.height > footer.right.contentSize.height {
                offset = max(0, footer.right.contentOffset.y - detal * 0.5)                         // 超出底部范围,增加减速因子
                if state == .ended {                                                                // 松手时切换仿真
                    let to = max(0, footer.right.contentSize.height - footer.right.bounds.height)   // 防止contentSize.height < 实际内容
                    switchSpringBehavior(on: footer.right, from: offset, to: to)
                }
            }
            footer.right.contentOffset = CGPoint.init(x: footer.right.contentOffset.x, y: offset)
            if offset == 0, detal > 0 {
                table.contentOffset = CGPoint.init(x: 0, y: maxY - detal)                           // 当向下拉至0时,触发父视图设置
            }else{
                table.contentOffset = CGPoint.init(x: 0, y: maxY)
            }
        }
    }
    func switchSpringBehavior(on table: UITableView, from: CGFloat, to: CGFloat) {
        guard let temp = decelerationBehavior else {
            return
        }
        self.animator.removeBehavior(temp)
        decelerationBehavior = nil
        dynamicItem.center = CGPoint.init(x: 0, y: from)                        // 设置仿真起点
        
        let spring = UIAttachmentBehavior.init(item: dynamicItem, attachedToAnchor: CGPoint.init(x: 0, y: to))
        spring.length = 0
        spring.damping = 1
        spring.frequency = 2
        spring.action = {
            table.contentOffset = self.dynamicItem.center
        }
        self.animator.addBehavior(spring)
    }
    
    var maxY: CGFloat {
        footer.frame.minY
    }
    let identify = "cell"
    let evenColo = UIColor.gray
    let oddColo = UIColor.lightGray
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
        tab.backgroundColor = UIColor.red
        tab.tableFooterView = footer
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identify)
        tab.isScrollEnabled = false
        tab.dataSource = self
        view.addSubview(tab)
        return tab
    }()
    lazy var footer: MBLinkageTableV2 = {
        let foo = MBLinkageTableV2.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight ))
        return foo
    }()
    lazy var pan: UIPanGestureRecognizer = {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(gesture(pan:)))
//        ges.delegate = self
        MBLog(ges)
        view.addGestureRecognizer(ges)
        return ges
    }()
    lazy var animator: UIDynamicAnimator = {
        let temp = UIDynamicAnimator.init(referenceView: table)
        return temp
    }()
}

extension MBMenuTest4ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        cell.backgroundColor = (indexPath.row % 2 == 0) ? evenColo : oddColo
        return cell
    }
}

//extension MBMenuTest4ViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == pan {
//            return false
//        }else{
//            return true
//        }
//    }
//}
