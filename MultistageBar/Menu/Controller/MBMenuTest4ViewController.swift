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
    
    var currentScorllY: CGFloat = 0
    var dynamicItem = LJDynamicItem.init()
    var decelerationBehavior: UIDynamicItemBehavior?
    
    @objc func gesture(pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: table)
        switch pan.state {
        case .began:
            currentScorllY = table.contentOffset.y
            animator.removeAllBehaviors()
        case .changed:
            verticalHandler(detal: point.y, state: pan.state)
        case .ended:
            dynamicItem.center = CGPoint.zero
            let velocity = pan.velocity(in: table)
            let behavior = UIDynamicItemBehavior.init(items: [dynamicItem])
            behavior.addLinearVelocity(CGPoint.init(x: 0, y: velocity.y), for: dynamicItem)
            behavior.resistance = 5
            var lastCenter = CGPoint.zero
            behavior.action = { [unowned self] in
                let detal = dynamicItem.center.y - lastCenter.y
                verticalHandler(detal: detal, state: .ended)
                lastCenter = dynamicItem.center
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
        // 未超出最大值,仅改变父容器的offset
        if table.contentOffset.y < maxY {
            table.contentOffset = CGPoint.init(x: 0, y: max(table.contentOffset.y - detal, 0))
        }else{
            // 超出最大值,固定父容器最大值为maxY,同时修改子视图的offset
            // 子视图的offset.y加上偏移量detal,由于detal向上滑为负,向下滑为正,所以这边不用判断,直接减去detal,
            // 达到向上增加detal的绝对值,向下减少detal的绝对值效果
            // 防止right超出上边界
            var sety = max(0, footer.right.contentOffset.y - detal)
            if sety + footer.right.bounds.height > footer.right.contentSize.height {
                // 防止right超出下边界
                sety = max(footer.right.contentSize.height - footer.right.bounds.height, 0)
            }
            let offset = CGPoint.init(x: footer.right.contentOffset.x, y: sety)
            footer.right.contentOffset = offset
            // 向下拉至right.contentoffset.y == 0时,修改table的y值
            if sety == 0, detal > 0 {
                table.contentOffset = CGPoint.init(x: 0, y: maxY - detal)
            }else{
                table.contentOffset = CGPoint.init(x: 0, y: maxY)
            }
        }
    }
    
    let maxY: CGFloat = 220
    let identify = "cell"
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
        tab.tableFooterView = footer
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identify)
        tab.isScrollEnabled = false
        tab.dataSource = self
        view.addSubview(tab)
        return tab
    }()
    lazy var footer: MBLinkageTableV2 = {
        let foo = MBLinkageTableV2.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 660 ))
        return foo
    }()
    lazy var pan: UIPanGestureRecognizer = {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(gesture(pan:)))
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
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
