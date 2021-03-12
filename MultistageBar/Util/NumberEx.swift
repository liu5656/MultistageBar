//
//  NumberEx.swift
//  MultistageBar
//
//  Created by x on 2021/3/12.
//  Copyright © 2021 x. All rights reserved.
//

import Foundation

extension Double {
    // 单位为秒,
    func time() -> String {
        let temp = Int(self)
        switch temp {
        case 0..<10:
            return "00:0\(temp)"
        case 10..<60:
            return "00:\(temp)"
        case 60..<600:
            return "0\(temp/60):\(temp%60)"
        case 600..<3600:
            return "\(temp/60):\(temp%60)"
        default:
            return ""
        }
    }
}
