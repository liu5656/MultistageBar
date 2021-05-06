//
//  MBMenuTest3ViewController.swift
//  MultistageBar
//
//  Created by x on 2021/4/27.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuTest3ViewController: MBViewController {
    
    @objc func mb_rightAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            colCV.collectionViewLayout = common
        }else{
            colCV.collectionViewLayout = horizontal
        }
        colCV.reloadData()
    }
    
    // life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = colCV
        _ = rightB
    }
    
    
    // porperties
    let cardCellIdentify: String = "specialOneIdentify"
    let cardHeaderIdentify: String = "specialTwoIdentify"
    
    
    lazy var datas: [[String]] = {
        var tes: [[String]] = []
//                for i in 1...2 {
//                    var temp: [String] = []
//                    for j in 0..<25 {
//                        temp.append("\(i)-\(j)")
//                    }
//                    tes.append(temp)
//                }
        for i in 1...31 {
            var temp: [String] = []
            var num = 5
            for j in 0..<i {
                temp.append("\(i)-\(j)")
            }
            tes.append(temp)
        }
        return tes
    }()
    lazy var rightB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.setTitleColor(UIColor.black, for: .normal)
        but.frame = CGRect.init(x: 0, y: 0, width: 30, height: 40)
        but.setTitle("切换layout", for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: but)
        but.addTarget(self, action: #selector(mb_rightAction(sender:)), for: .touchUpInside)
        return but
    }()
    lazy var common: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right:10)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let width = (360 - 10 - 10 * 4 - 10) / 5
        layout.itemSize = CGSize.init(width: width, height: 60)
        return layout
    }()
    lazy var horizontal: MBSpecialHorizontalLayout = {
        //        let layout = MBSpecialHorizontalLayout.init()
        //        layout.delegate = self
        //        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right:10)
        //        layout.scrollDirection = .horizontal
        //        layout.minimumLineSpacing = 10
        //        layout.minimumInteritemSpacing = 10
        //        let width = (360 - 10 - 10 * 4 - 10) / 5
        //        layout.itemSize = CGSize.init(width: width, height: 60)
        
        let layout = MBSpecialHorizontalLayout.init()
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)
//        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 30
        let itemW = (Screen.width - 26 - 4 * 30 - 26) / 5
        layout.itemSize = CGSize(width: itemW, height: 54)
        return layout
    }()
    
    lazy var colCV: UICollectionView = {
        //        let col = UICollectionView.init(frame: CGRect.init(x: 0, y: 100, width: 360, height: 200), collectionViewLayout: horizontal)
        let col = UICollectionView.init(frame: CGRect.init(x: 0, y: 100, width: Screen.width, height: 174), collectionViewLayout: horizontal)
        col.backgroundColor = UIColor.gray
        col.isPagingEnabled = true
        //        col.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        col.register(MBCardCell.classForCoder(), forCellWithReuseIdentifier: cardCellIdentify)
        col.register(UINib.init(nibName: "MBCardHeader", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cardHeaderIdentify)
        col.showsVerticalScrollIndicator = false
        col.showsHorizontalScrollIndicator = false
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
        let supplement = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cardHeaderIdentify, for: indexPath)
        //        MBLog(indexPath)
        if let temp = supplement as? MBCardHeader {
            temp.title.text = "card header \(indexPath.section)"
        }
        
        return supplement
    }
}

//extension MBMenuTest3ViewController: UICollectionViewDelegateFlowLayout {
//
//    // 返回的size,根据滑动方向,只有一个属性生效
//    // 横向是宽度生效,高度是collectionView的高度
//    // 竖向是高度生效,宽度是collectionView的宽度
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if 1 == section {
//            return CGSize.init(width: 300, height: 60)
//        }else{
//            return .zero
//        }
//    }
//}

extension MBMenuTest3ViewController: MBSpecialHorizontalLayoutDelegate {
    func layout(_: MBSpecialHorizontalLayout, headerIn section: Int) -> Bool {
        if 1 == section % 2 {
            return true
        }
        return false
    }
    func layout(_: MBSpecialHorizontalLayout, refreenceSizeForHeaderIn section: Int) -> CGSize {
        return CGSize.init(width: 0, height: 60)
    }
}


