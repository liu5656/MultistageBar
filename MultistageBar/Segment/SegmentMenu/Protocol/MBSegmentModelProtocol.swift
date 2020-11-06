//
//  MBSegmentModel.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol MBSegmentModelProtocol: AnyObject {
    var style: MBSegmentModelStyleProtocol {set get}
    func mb_size() -> CGSize
}
