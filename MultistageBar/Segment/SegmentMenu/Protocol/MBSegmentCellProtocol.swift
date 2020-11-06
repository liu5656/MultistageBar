//
//  MBSegmentCellProtocol.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol MBSegmentCellProtocol: AnyObject {
    func mb_update(model: MBSegmentModelProtocol)
    func mb_update(style: MBSegmentModelStyleProtocol)
    func mb_willFocus(_ focus: Bool, scale: CGFloat)
}
