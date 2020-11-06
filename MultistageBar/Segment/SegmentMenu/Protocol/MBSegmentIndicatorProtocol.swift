//
//  MBSegmentIndicatorProtocol.swift
//  MultistageBar
//
//  Created by x on 2020/4/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol MBSegmentIndicatorProtocol: AnyObject {
    func mb_slider(fromWidth: CGFloat, fromCenter: CGPoint, toWidth: CGFloat, toCenter: CGPoint, scale: CGFloat)
}
