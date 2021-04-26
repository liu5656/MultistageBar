//
//  MBLinkageTable.swift
//  MultistageBar
//
//  Created by x on 2021/4/26.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

protocol MBLinkageTableDatasource: CellIdentifyProtocol {
    var nest: [CellIdentifyProtocol] { get set }
}


class MBLinkageTable: UIScrollView {
    func add(header: UIView) {
        topY = header.frame.maxY
        addSubview(header)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        panGestureRecognizer.delegate = self
//        bounces = false
        
        _ = left
        _ = right
        delegate = self
        contentSize = CGSize.init(width: bounds.width, height: bounds.height + topY)
    }
    
    
    var topY: CGFloat = 400
    let leftIdentify = "leftIdentify"
    let rightIdentify = "rightIdentify"
    var isPart = false
    var selectPart: Int = 0
    var upperCanScroll = false
    var datas: [MBLinkageTableDatasource] = [] {
        didSet{
            if let temp = datas.first {
                left.register(temp.cellClass, forCellWithReuseIdentifier: temp.identify)
            }
            if let temp = datas.first?.nest.first {
                right.register(temp.cellClass, forCellWithReuseIdentifier: temp.identify)
            }
            DispatchQueue.main.async { [weak self] in
                self?.left.reloadData()
                self?.right.reloadData()
            }
        }
    }
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

extension MBLinkageTable: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MBLog(indexPath)
        if collectionView == left {
            let index = IndexPath.init(row: 0, section: indexPath.row)
            UIView.animate(withDuration: 0.2) {
                self.contentOffset.y = self.topY
            }
            if isPart {
                selectPart = indexPath.row
                right.reloadData()
            }else{
                right.scrollToItem(at: index, at: .top, animated: true)
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == left || isPart {
            return 1
        }else{
            return datas.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == left {
            return datas.count
        }else if isPart {
            return datas[selectPart].nest.count
        }else{
            return datas[section].nest.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model: CellIdentifyProtocol
        if collectionView == left {
            model = datas[indexPath.row]
        }else if isPart {
            model = datas[selectPart].nest[indexPath.row]
        }else{
            model = datas[indexPath.section].nest[indexPath.row]
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identify, for: indexPath)
        if let temp = cell as? CellContentProtocol {
            temp.config(model: model)
        }
        return cell
    }
}

extension MBLinkageTable: UIScrollViewDelegate {
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

extension MBLinkageTable: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
