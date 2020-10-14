//
//  DDLSegmentCellProtocol.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentCellProtocol: AnyObject {
    func ddl_update(model: DDLSegmentModelProtocol)
    func ddl_update(style: DDLSegmentModelStyleProtocol)
    func ddl_willFocus(_ focus: Bool, scale: CGFloat)
}
