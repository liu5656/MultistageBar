//
//  DDLSegmentIndicatorProtocol.swift
//  MultistageBar
//
//  Created by x on 2020/4/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentIndicatorProtocol: AnyObject {
    func ddl_slider(fromWidth: CGFloat, fromCenter: CGPoint, toWidth: CGFloat, toCenter: CGPoint, scale: CGFloat)
}

class DDLSegmentBaseIndicator: UIView, DDLSegmentIndicatorProtocol {
    var paddingWidth: CGFloat = 0 // 单边
    func ddl_slider(fromWidth: CGFloat, fromCenter: CGPoint, toWidth: CGFloat, toCenter: CGPoint, scale: CGFloat){
        let width = fromWidth - paddingWidth * 2 + (toWidth - fromWidth) * scale
        let x = fromCenter.x + (toCenter.x - fromCenter.x) * scale - width * 0.5
        frame = CGRect.init(x: x, y: frame.origin.y, width: width, height: frame.height)
    }
}

class DDLSegmentLineIndicator: DDLSegmentBaseIndicator {
}

class DDLSegmentBackgroundIndicator: DDLSegmentBaseIndicator {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        layer.cornerRadius = frame.height * 0.5
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
