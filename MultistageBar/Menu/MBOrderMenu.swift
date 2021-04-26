//
//  MBOrderMenu.swift
//  MultistageBar
//
//  Created by x on 2021/2/23.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

// 参考:https://www.tutorialfor.com/blog-276252.htm   https://www.tyrad.cc/2018/ios-ges-conflict/
// 格式
//                left:UICollectionView
// UIScrollView {
//                right:UICollectionView

class MBOrderMenu: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        panGestureRecognizer.delegate = self
//        bounces = false
        
        _ = left
        _ = right
        delegate = self
        contentSize = CGSize.init(width: bounds.width, height: bounds.height + topY)
    }
    let topY: CGFloat = 400
    let leftIdentify = "leftIdentify"
    let rightIdentify = "rightIdentify"
    var upperCanScroll = false
    var lowerCanScroll = false
    lazy var leftDatas: [String] = {
        var res: [String] = []
        for i in 0..<20 {
            res.append("\(i)")
        }
        return res
    }()
    lazy var rightDatas: [String] = {
        var res: [String] = []
        for i in 0..<10 {
            res.append("\(i)")
        }
        return res
    }()
    lazy var left: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = CGSize.init(width: 200, height: 44)
        
        let col = UICollectionView.init(frame: CGRect.init(x: 0, y: topY, width: 200, height: bounds.height), collectionViewLayout: layout)
        col.tag = 1
        col.bounces = false
        col.backgroundColor = UIColor.gray
        col.register(MBMenuItemCell.classForCoder(), forCellWithReuseIdentifier: rightIdentify)
        col.delegate = self
        col.dataSource = self
        addSubview(col)
        return col
        
    }()
    lazy var right: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 10, right: 10)
        
        let col = UICollectionView.init(frame: CGRect.init(x: left.frame.maxX, y: left.frame.origin.y, width: Screen.width - left.frame.width, height: left.frame.height), collectionViewLayout: layout)
        col.tag = 2
        col.bounces = false
        col.backgroundColor = UIColor.gray
        col.register(MBMenuItemCell.classForCoder(), forCellWithReuseIdentifier: rightIdentify)
        col.delegate = self
        col.dataSource = self
        addSubview(col)
        return col
    }()
}

extension MBOrderMenu: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MBLog(indexPath)
        if collectionView == left {
            let index = IndexPath.init(row: 0, section: indexPath.row)
            UIView.animate(withDuration: 0.2) {
                self.contentOffset.y = self.topY
            }
            right.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == left {
            return 1
        }else{
            return leftDatas.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == left {
            return leftDatas.count
        }else{
            return rightDatas.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rightIdentify, for: indexPath)
        if let temp = cell as? MBMenuItemCell {
            if collectionView == left {
                temp.titleL.text =  leftDatas[indexPath.row] + "左边菜单"
            }else{
                temp.titleL.text = leftDatas[indexPath.section] + "-" + rightDatas[indexPath.row]
            }
        }
        return cell
    }
}

extension MBOrderMenu: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if scrollView == self {
            if upperCanScroll == false {
                right.contentOffset.y = 0
                left.contentOffset.y = 0
            }
            if offsetY >= topY {
                upperCanScroll = true
                self.contentOffset.y = topY
            }
//            MBLog("bottom: \(offsetY)")
        }else{
//            MBLog("left: \(offsetY)")
            if upperCanScroll, 0 < offsetY {
                self.contentOffset.y = topY
            }
            if 0 >= offsetY {
                upperCanScroll = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == right {
            updateIndexFor(scroll: scrollView)
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == right, decelerate == false {
            updateIndexFor(scroll: scrollView)
        }
    }
    func updateIndexFor(scroll: UIScrollView) {
        let point = convert(CGPoint.init(x: left.frame.maxX + 20, y: topY), to: right)
        guard let row = right.indexPathForItem(at: point)?.section else {
            return
        }
        left.selectItem(at: IndexPath.init(row: row, section: 0), animated: true, scrollPosition: .top)
    }
}

extension MBOrderMenu: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
