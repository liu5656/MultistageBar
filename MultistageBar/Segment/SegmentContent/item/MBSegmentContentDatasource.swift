//
//  MBSegmentContentDatasource.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol MBSegmentContentDatasource: AnyObject {
    func mb_segmentContentNumber() -> Int
    func mb_segmentContent(cellForItemAt index: Int) -> MBSegmentContentItemProtocol
}

protocol MBSegmentContentItemProtocol: AnyObject {
    func mb_view() -> UIView
}
