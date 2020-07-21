//
//  DDLMultistageViewController.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class DDLMultistageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        _ = segment
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
            DispatchQueue.main.async {
                self.ddl_loadData()
            }
        }
    }
    deinit {
        print("ViewController deinit")
    }
    
    func ddl_loadData() {
        
        let data1 = DDLSegmentModelTitle.init()
        data1.style = style
        data1.name = "交通工具"
        
        let data2 = DDLSegmentModelTitle.init()
        data2.style = style
        data2.name = "数码"
        
        let data3 = DDLSegmentModelTitle.init()
        data3.style = style
        data3.name = "食物"
        datasource = [data1, data2, data3]
        segment.datasource = datasource
    }
   
    lazy var style: DDLSegmentItemProtocol = {
        let temp = DDLSegmentItemTitle.init()
        temp.normalColor = UIColor.blue
        temp.normalFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        temp.selectedColor = UIColor.red
        temp.selectedFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        temp.paddingWidth = 15
        temp.paddingHeight = 4
        return temp
    }()
    lazy var header: DDLSegmentHeader = {
        let temp = DDLSegmentHeader.init()
        temp.frame = CGRect.init(x: 0, y: 0, width: 414, height: 100)                       // 真实width值和height值
        temp.backgroundColor = UIColor.green
        view.addSubview(temp)
        return temp
    }()
    lazy var indicator: DDLSegmentIndicatorProtocol = {
        let temp = DDLSegmentBackgroundIndicator.init()
        temp.frame = CGRect.init(x: 0, y: 0, width: 60, height: 30)                         // 真实y值和height值
        temp.layer.cornerRadius = 15
        temp.backgroundColor = UIColor.lightGray
        return temp
    }()
    
    var datasource: [DDLSegmentModelProtocol] = []
    lazy var segment: DDLSegmentMenuView = {
        let temp = DDLSegmentMenuView.init(frame: CGRect.init(x: 0, y: 100, width: 414, height: 50))
        temp.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)         // segment 边距
        temp.contentRadius = 15                                                             // segment 圆角
        temp.contentColor = UIColor.green                                                   // segment背景
        temp.itemHeight = 30                                                                // segment 单项高度 = itemHeight + sectionInset.left + sectionInset.right
        print("+++++ set lineSpacing \(5)")
        temp.lineSpacing = 5
        temp.datasource = datasource                                                        // menu数据源
        temp.indicator = indicator                                                          // 选中的指示器
        temp.contentDatasource = self                                                       // content数据代理
        temp.ddl_show(in: self.view, contentFrame: CGRect.init(x: 0, y: temp.frame.maxY, width: temp.frame.width, height: UIScreen.main.bounds.height - temp.frame.maxY))   // 添加到父视图
        return temp
    }()
}

extension DDLMultistageViewController: DDLSegmentContentDatasource {
    func ddl_segmentContentNumber() -> Int {
        return datasource.count
    }
    
    func ddl_segmentContent(cellForItemAt index: Int) -> DDLSegmentContentItemProtocol {
        let vc = DDLFirstTableContentVC.init()
        if 0 == index {
            vc.titles = ["非常大的货车", "自行车", "手机", "afldsjasdjf", "fasdfsadfsadfsadfa", "fsadfasdfasd", "fasdfsadfsadfsadfa", "fsadfasdfasd"]
        }else if 1 == index {
            vc.titles = ["手机", "笔记本电脑", "airPods"]
        }else if 2 == index {
            let vc = DDLView.init()
            vc.backgroundColor = UIColor.init(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1)
            return vc
        }
        vc.view.backgroundColor = UIColor.init(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1)
        return vc
    }
}

