//
//  MBDistance.swift
//  MultistageBar
//
//  Created by x on 2020/11/3.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation

struct MBDistance {
    
    static let degressToRadian = Double.pi / 180
    static let earthRadius = 6371000.0
    
    static func calculate(begin: MBCoordination, to: MBCoordination) -> Double {
        let latBegin = degressToRadian * begin.lat
        let latTo = degressToRadian * to.lat
        let latDelta = latBegin - latTo
        let lonDelta = (begin.lon  - to.lon) * degressToRadian
        let disRatio = 2 * asin(sqrt(pow(sin(latDelta / 2), 2) + cos(latBegin) * cos(latTo) * pow(sin(lonDelta / 2), 2)))
        let ditanceDelta = disRatio * earthRadius
        return ditanceDelta
    }
    
    /// 通过起始点与终点经纬度以及海拔差值计算距离
    public static func distanceWithAltitude(begin: MBCoordination, beginAltitude: Double, to: MBCoordination, toAltitude: Double) -> Double{
        let latBegin = degressToRadian * begin.lat
        let latTo = degressToRadian * to.lat
        let latDelta = latBegin - latTo
        let lonDelta = (begin.lon  - to.lon) * degressToRadian
        let a = pow(sin(latDelta / 2), 2) + cos(latBegin) * cos(latTo) * pow(sin(lonDelta / 2), 2)
        let b = 2 * atan2(sqrt(a), sqrt(1 - a))
        var distanceAlta = earthRadius * b
        let altDelta = beginAltitude - toAltitude
        distanceAlta = sqrt(distanceAlta * distanceAlta + altDelta * altDelta)
        return distanceAlta
    }
}
