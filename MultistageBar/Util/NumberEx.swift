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

extension Int {
    // 0 -> 0
    // 不足一倍, 1倍 -> 1
    // n倍有余 -> n + 1
    func divided(_ num: Int) -> (Int, Int) {
        guard 0 != self else {
            return (0, 0)
        }
        var res = self / num
        let remainder = self % num
        if remainder != 0  {
            res += 1
        }
        return (res, remainder)
    }
}
