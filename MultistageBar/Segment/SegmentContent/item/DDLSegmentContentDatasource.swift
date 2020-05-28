//
//  DDLSegmentContentDatasource.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentContentDatasource: AnyObject {
    func ddl_segmentContentNumber() -> Int
    func ddl_segmentContent(cellForItemAt index: Int) -> DDLSegmentContentItemProtocol
}

protocol DDLSegmentContentItemProtocol: AnyObject {
    func ddl_view() -> UIView
}
