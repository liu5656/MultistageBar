//
//  MBSegmentTableContent.swift
//  MultistageBar
//
//  Created by x on 2020/4/26.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBFirstTableContentVC: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = segment
        segment.datasource = datasource
        print("DDLFirstTableContentVC init \(self)")
    }
    deinit {
        print("DDLFirstTableContentVC deinit \(self)")
    }
    
    lazy var style: MBSegmentModelStyleProtocol = {
        let temp = MBSegmentModelTitleStyle.init()
        return temp
    }()
    var titles: [String] = []
    
    lazy var indicator: MBSegmentLineIndicator = {
        let temp = MBSegmentLineIndicator.init()
        temp.frame = CGRect.init(x: 0, y: 35, width: 100, height: 4)
        temp.layer.cornerRadius = 2
        temp.backgroundColor = UIColor.red
        return temp
    }()
    
    lazy var datasource: [MBSegmentModelProtocol] = {
        var temp: [MBSegmentModelTitle] = []
        titles.enumerated().forEach { (title) in
            let data1 = MBSegmentModelTitle.init(style: style)
            data1.name = title.element
            data1.badge = title.offset * 6
            temp.append(data1)
        }
        return temp
    }()
    
    lazy var segment: MBSegmentMenuView = {
        let temp = MBSegmentMenuView.init(frame: CGRect.init(x: 0, y: 0, width: 414, height: 50))
        temp.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
//        temp.datasource = datasource
        temp.lineSpacing = 10
//        temp.itemSpacing = 10
        print("+++++ set lineSpacing \(10)")
        temp.contentDatasource = self
        temp.indicator = indicator
        temp.mb_show(in: self.view, contentFrame: CGRect.init(x: 0, y: temp.frame.maxY, width: temp.frame.width, height: UIScreen.main.bounds.height - 150 - 50))
        return temp
    }()
}

extension MBFirstTableContentVC: MBSegmentContentItemProtocol{
    func mb_view() -> UIView {
        return self.view
    }
}

extension MBFirstTableContentVC: MBSegmentContentDatasource {
    func mb_segmentContentNumber() -> Int {
        return datasource.count
    }
    
    func mb_segmentContent(cellForItemAt index: Int) -> MBSegmentContentItemProtocol {
        if 2 >= index {
            return MBSecondTableContentVC.init()
        }else{
            let vc = MBView.init()
            vc.backgroundColor = UIColor.init(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1)
            return vc
        }
    }
}


class MBView: UIView, MBSegmentContentItemProtocol {
    func mb_view() -> UIView {
        return self
    }
}

