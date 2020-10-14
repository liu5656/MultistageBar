//
//  DDLSegmentModel.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentModelProtocol: AnyObject {
    var style: DDLSegmentModelStyleProtocol? {set get}
    func ddl_size() -> CGSize
}
