//
//  MBMenuTest3ViewController.swift
//  MultistageBar
//
//  Created by x on 2021/4/27.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuTest3ViewController: MBViewController {
    
    // life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = colCV
    }
    
    // porperties
    let cardCellIdentify: String = "specialOneIdentify"
    let cardHeaderIdentify: String = "specialTwoIdentify"
    
    
    lazy var datas: [[String]] = {
        var tes: [[String]] = []
        for i in 0..<5 {
            var temp: [String] = []
            for j in 0..<5 {
                temp.append("\(i)-\(j)")
            }
            tes.append(temp)
        }
        return tes
    }()
    lazy var colCV: UICollectionView = {
        let layout = MBSpecialHorizontalLayout.init()
//        let layout = MBHorizontalLayout.init()
//        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
//        let width = (Screen.width - 40 - 40) / 5
        layout.itemSize = CGSize.init(width: 60, height: 60)
        
//        layout.sectionHeadersPinToVisibleBounds = true
//        layout.sectionFootersPinToVisibleBounds = true
        
//        layout.scrollDirection = .horizontal
//        let margin: CGFloat = 20
//        let itemW: CGFloat = (Screen.width - margin * 6) / 5
//        layout.minimumLineSpacing = margin
//        layout.minimumInteritemSpacing = 14
//        layout.itemSize = CGSize(width: itemW, height: 60)
//        layout.sectionInset = UIEdgeInsets(top: 5, left: margin, bottom: 0, right: margin)
        
        let col = UICollectionView.init(frame: CGRect.init(x: 0, y: 100, width: Screen.width, height: 200), collectionViewLayout: layout)
        col.backgroundColor = UIColor.gray
//        col.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        col.register(MBCardCell.classForCoder(), forCellWithReuseIdentifier: cardCellIdentify)
        col.register(UINib.init(nibName: "MBCardHeader", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cardHeaderIdentify)
        col.dataSource = self
        col.delegate = self
        view.addSubview(col)
        return col
    }()
}

extension MBMenuTest3ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    // UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MBLog(indexPath)
    }
    // UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datas.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas[section].count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = datas[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardCellIdentify, for: indexPath)
        if let temp = cell as? MBCardCell {
            temp.title.text = model
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let temp = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cardHeaderIdentify, for: indexPath)
        return temp
    }
}

extension MBMenuTest3ViewController: UICollectionViewDelegateFlowLayout {
    
    // 返回的size,根据滑动方向,只有一个属性生效
    // 横向是宽度生效,高度是collectionView的高度
    // 竖向是高度生效,宽度是collectionView的宽度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if 0 == section {
            return CGSize.init(width: 300, height: 60)
//        }else{
//            return .zero
//        }
    }
}


