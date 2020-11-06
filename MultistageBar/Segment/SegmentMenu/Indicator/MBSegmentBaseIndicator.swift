//
//  MBSegmentBaseIndicator.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBSegmentBaseIndicator: UIView, MBSegmentIndicatorProtocol {
    var paddingWidth: CGFloat = 0 // 单边
    func mb_slider(fromWidth: CGFloat, fromCenter: CGPoint, toWidth: CGFloat, toCenter: CGPoint, scale: CGFloat){
        let width = fromWidth - paddingWidth * 2 + (toWidth - fromWidth) * scale
        let x = fromCenter.x + (toCenter.x - fromCenter.x) * scale - width * 0.5
        frame = CGRect.init(x: x, y: frame.origin.y, width: width, height: frame.height)
    }
}
