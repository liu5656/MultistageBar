//
//  MBOrderMenu.swift
//  MultistageBar
//
//  Created by x on 2021/2/23.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

// 参考:https://www.tutorialfor.com/blog-276252.htm   https://www.tyrad.cc/2018/ios-ges-conflict/

class MBOrderMenu: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        panGestureRecognizer.delegate = self
//        bounces = false
        
        left.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .middle)
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
        for i in 0..<200 {
            res.append("\(i)")
        }
        return res
    }()
    lazy var left: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: topY, width: 200, height: bounds.height))
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: leftIdentify)
        tab.bounces = false
        tab.dataSource = self
        tab.delegate = self
//        tab.isScrollEnabled = false
        addSubview(tab)
        return tab
    }()
    lazy var right: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 10, right: 10)
        
        let col = UICollectionView.init(frame: CGRect.init(x: left.frame.maxX, y: left.frame.origin.y, width: Screen.width - left.frame.width, height: left.frame.height), collectionViewLayout: layout)
        col.backgroundColor = UIColor.gray
        col.register(MBMenuItemCell.classForCoder(), forCellWithReuseIdentifier: rightIdentify)
        col.delegate = self
        col.dataSource = self
//        col.isScrollEnabled = false
        addSubview(col)
        return col
    }()

}

extension MBOrderMenu: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MBLog(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leftDatas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: leftIdentify, for: indexPath)
        cell.textLabel?.text = "左边菜单:" + leftDatas[indexPath.row]
        return cell
    }
}

extension MBOrderMenu: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MBLog(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rightDatas.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rightIdentify, for: indexPath)
        if let temp = cell as? MBMenuItemCell {
            temp.titleL.text =  rightDatas[indexPath.row] + "左边菜单"
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
            MBLog("bottom: \(offsetY)")
        }else if scrollView == right {
            MBLog("right: \(offsetY)")
            if upperCanScroll, 0 < offsetY {
                self.contentOffset.y = topY
            }
            if 0 >= offsetY {
                upperCanScroll = false
            }
        }
    }
}

extension MBOrderMenu: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
