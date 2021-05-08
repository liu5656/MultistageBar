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
        animator = UIDynamicAnimator.init(referenceView: table)
    }
    
    var currentScorllY: CGFloat = 0
    
    var animator: UIDynamicAnimator!
    var dynamicItem = LJDynamicItem.init()
    var decelerationBehavior: UIDynamicItemBehavior?
    private func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
        let constant: CGFloat = 0.55
        let result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
        // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
        return offset < 0 ? -result : result
    }
    @objc func gesture(pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: table)
        MBLog(" ---- \(point)")
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
        default:
            break
        }
        pan.setTranslation(CGPoint.zero, in: view)
    }
    
    
    
    func verticalHandler(detal: CGFloat, state: UIGestureRecognizer.State) {
        //判断是主ScrollView滚动还是子ScrollView滚动,detal为手指移动的距离
        if table.contentOffset.y >= maxY {
            var offsetY = footer.right.contentOffset.y - detal
            if offsetY < 0 {
                offsetY = 0
                table.contentOffset = CGPoint.init(x: table.frame.origin.x, y: table.contentOffset.y - detal)
            }else if offsetY > (footer.right.contentSize.height - footer.right.bounds.height) {
                offsetY = footer.right.contentOffset.y - rubberBandDistance(offset: detal, dimension: table.bounds.height)
            }
            table.contentOffset = CGPoint.init(x: 0, y: offsetY)
        }else{
            if footer.right.contentOffset.y != 0 && detal >= 0 {
                var offsetY = footer.right.contentOffset.y - detal
                if offsetY < 0 {
                    offsetY = 0
                    table.contentOffset = CGPoint.init(x: table.frame.origin.x, y: table.contentOffset.y - detal)
                }else if offsetY > (footer.right.contentSize.height - footer.right.bounds.height) {
                    offsetY = footer.right.contentOffset.y - rubberBandDistance(offset: detal, dimension: table.bounds.height)
                }
                footer.right.contentOffset = CGPoint.init(x: 0, y: offsetY)
            }else{
                var mainOffsetY = table.contentOffset.y - detal;
                if (mainOffsetY < 0) {
                    //滚到顶部之后继续往上滚动需要乘以一个小于1的系数
                    mainOffsetY = table.contentOffset.y - rubberBandDistance(offset: detal, dimension: table.bounds.height);
                    
                } else if (mainOffsetY > maxY) {
                    mainOffsetY = maxY;
                }
                table.contentOffset = CGPoint.init(x: table.frame.origin.x, y: mainOffsetY)
                if (mainOffsetY == 0) {
                    footer.right.contentOffset = CGPoint.zero
                }
            }
        }
        
        
//        BOOL outsideFrame = self.contentOffset.y < 0 || self.subTableView.contentOffset.y > (self.subTableView.contentSize.height - self.subTableView.frame.size.height);
//        BOOL isMore = self.subTableView.contentSize.height >= self.subTableView.frame.size.height || self.contentOffset.y >= _maxOffset_Y||self.contentOffset.y < 0 ;
//        if (isMore && outsideFrame && (self.decelerationBehavior && !self.springBehavior)) {
//            CGPoint target = CGPointZero;
//            BOOL isMian = NO;
//            if (self.contentOffset.y < 0) {
//                self.dynamicItem.center = self.contentOffset;
//                target = CGPointZero;
//                isMian = YES;
//            } else if (self.subTableView.contentOffset.y > (self.subTableView.contentSize.height - self.subTableView.frame.size.height)) {
//                self.dynamicItem.center = self.subTableView.contentOffset;
//
//                target = CGPointMake(self.subTableView.contentOffset.x, (self.subTableView.contentSize.height - self.subTableView.frame.size.height));
//                //********判断tableview的contentsize.height是否大于自身高度，从而控制滚动/
//                if (self.subTableView.contentSize.height <= self.subTableView.frame.size.height) {
//                    target = CGPointMake(self.subTableView.contentOffset.x,0);
//                }
//                isMian = NO;
//            }
//            [self.animator removeBehavior:self.decelerationBehavior];
//            __weak typeof(self) weakSelf = self;
//            UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
//            springBehavior.length = 0;
//            springBehavior.damping = 1;
//            springBehavior.frequency = 2;
//            springBehavior.action = ^{
//                if (isMian) {
//                    weakSelf.contentOffset = weakSelf.dynamicItem.center;
//                    if (weakSelf.contentOffset.y == 0) {
//                        self.subTableView.contentOffset = CGPointMake(0, 0);
//                    }
//                } else {
//
//                    weakSelf.subTableView.contentOffset = self.dynamicItem.center;
//                }
//            };
//            [self.animator addBehavior:springBehavior];
//            self.springBehavior = springBehavior;
//        }
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
        let foo = MBLinkageTableV2.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 880 ))
        return foo
    }()
    
    lazy var pan: UIPanGestureRecognizer = {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(gesture(pan:)))
        view.addGestureRecognizer(ges)
        return ges
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
