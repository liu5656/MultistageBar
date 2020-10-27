//
//  MBRefreshTestViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBRefreshTestViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.init()
        _ = collectionCV
    }
    
    let cellIdentify = "cellIdentify"
    lazy var collectionCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight - 12)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let col = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight), collectionViewLayout: layout)
//        col.contentInset = UIEdgeInsets.init(top: 13, left: 12, bottom: 12, right: 12)
        col.contentInsetAdjustmentBehavior = .never
        col.alwaysBounceVertical = false
        col.backgroundColor = UIColor.white
        col.isPagingEnabled = true
        col.dataSource = self
        col.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: cellIdentify)
        
        col.refreshHeader {
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                DispatchQueue.main.async {
                    col.endHeaderRefreshing()
                }
            }
        }
        view.addSubview(col)
        return col
    }()
}

extension MBRefreshTestViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentify, for: indexPath)
        cell.backgroundColor = UIColor.gray
        return cell
    }
}
