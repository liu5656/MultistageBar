//
//  MBCornerMarkViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBCornerMarkViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let data1 = MBSegmentModelTitle.init(style: style)
        data1.name = "交通工具"
        data1.badge = 1
        
        let data2 = MBSegmentModelTitle.init(style: style)
        data2.name = "数码"
        data2.badge = 8
        
        let data3 = MBSegmentModelTitle.init(style: style)
        data3.name = "食物"
        data3.badge = 99
        datasource = [data1, data2, data3]
        
        
        segment.datasource = datasource
        
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
            self.segment.datasource.forEach { (model) in
                if let temp = model as? MBSegmentModelTitle {
                    temp.badge += 2
                }
            }
            DispatchQueue.main.async {
                self.segment.mb_reloadDataTitle()
            }
        }
        
        
    }
    
    var datasource: [MBSegmentModelProtocol] = []
    lazy var style: MBSegmentModelStyleProtocol = {
        let temp = MBSegmentModelTitleStyle.init()
        temp.normalColor = UIColor.blue
        temp.normalFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        temp.selectedColor = UIColor.red
        temp.selectedFont = UIFont.systemFont(ofSize: 16, weight: .bold)
//        temp.paddingWidth = 15
//        temp.paddingHeight = 4
        return temp
    }()
    lazy var indicator: MBSegmentIndicatorProtocol = {
        let temp = MBSegmentBackgroundIndicator.init()
        temp.frame = CGRect.init(x: 0, y: 0, width: 60, height: 30)                         // 真实y值和height值
        temp.layer.cornerRadius = 15
        temp.backgroundColor = UIColor.lightGray
        return temp
    }()
    lazy var segment: MBSegmentMenuView = {
        let temp = MBSegmentMenuView.init(frame: CGRect.init(x: 0, y: 100, width: 414, height: 50))
        temp.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)         // segment 边距
        temp.contentRadius = 15                                                             // segment 圆角
        temp.contentColor = UIColor.green                                                   // segment背景
        temp.itemHeight = 30                                                                // segment 单项高度 = itemHeight + sectionInset.left + sectionInset.right
        temp.lineSpacing = 5
        temp.datasource = datasource                                                        // menu数据源
        temp.indicator = indicator                                                          // 选中的指示器
        temp.mb_show(in: self.view, contentFrame: .zero)   // 添加到父视图
        return temp
    }()
    
}
