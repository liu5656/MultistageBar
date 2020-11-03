//
//  MBCoordination.swift
//  MultistageBar
//
//  Created by x on 2020/11/3.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation

class MBCoordination {
    var lat: Double = 0 {
        willSet{
            if newValue > 90, newValue < -90 {
                fatalError("-90 <= 维度 <= 90")
            }
        }
    }
    var lon: Double = 0 {
        willSet {
            if newValue > 180, newValue < -180 {
                fatalError("-180 <= 经度 <= 180")
            }
        }
    }
    init(lon: Double, lat: Double) {
        self.lat = lat
        self.lon = lon
    }
}
