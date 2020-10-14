//
//  DDLSegmentModelTitleStyle.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class DDLSegmentModelTitleStyle: DDLSegmentModelStyleProtocol {
    // 基本样式配置
    var normalColor: UIColor = UIColor.lightGray
    var selectedColor: UIColor = UIColor.black
    var normalFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    var selectedFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    
    // DDLSegmentModelStyleProtocol
    var identify: String = "cell"
    var cellClass: AnyClass = DDLSegmentTitleCell.self
}
