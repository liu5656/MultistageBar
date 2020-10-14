//
//  DDLSegmentBaseItem.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentModelStyleProtocol: AnyObject {
    var identify: String{set get}
    var cellClass: AnyClass {get set}
}
