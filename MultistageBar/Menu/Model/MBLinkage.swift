//
//  MBLinkage.swift
//  MultistageBar
//
//  Created by x on 2021/4/26.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBLinkage: NSObject, MBLinkageTableDatasource {
    var cellClass: AnyClass = MBMenuItemCell.classForCoder()
    var identify: String = NSStringFromClass(MBMenuItemCell.classForCoder())

    var nest: [CellIdentifyProtocol] = []
    
    var title: String?
}

class MBSubLinkage: NSObject, CellIdentifyProtocol {
    var cellClass: AnyClass = MBMenuItemCell.classForCoder()
    var identify: String = NSStringFromClass(MBMenuItemCell.classForCoder())
    
    var title: String?
}
