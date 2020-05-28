//
//  DDLSegmentBaseItem.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit



protocol DDLSegmentItemProtocol: AnyObject {
    func ddl_widthPadding() -> CGFloat
    func ddl_heightPadding() -> CGFloat
    func ddl_registerCell(in collection: UICollectionView)
    func ddl_cell(in collection: UICollectionView, for index: IndexPath) -> DDLSegmentCellProtocol
}

class DDLSegmentItemTitle {
    // 基本样式配置
    var paddingWidth: CGFloat = 0
    var paddingHeight: CGFloat = 0
    var normalColor: UIColor = UIColor.lightGray
    var selectedColor: UIColor = UIColor.black
    var normalFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    var selectedFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    
    // cell配置
    let identify = "cell"
    let cellClass = DDLSegmentTitleCell.self
}

extension DDLSegmentItemTitle: DDLSegmentItemProtocol {
    func ddl_widthPadding() -> CGFloat {
        return paddingWidth
    }
    
    func ddl_heightPadding() -> CGFloat {
        return paddingHeight
    }
    
    func ddl_registerCell(in collection: UICollectionView) {
        collection.register(cellClass, forCellWithReuseIdentifier: identify)
    }
    
    func ddl_cell(in collection: UICollectionView, for index: IndexPath) -> DDLSegmentCellProtocol {
        return collection.dequeueReusableCell(withReuseIdentifier: identify, for: index) as! DDLSegmentCellProtocol
    }
}
