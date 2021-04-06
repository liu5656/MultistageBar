//
//  MBDistanceViewController.swift
//  MultistageBar
//
//  Created by x on 2020/7/21.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBDistanceViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        mb_distanceTest()
    }
    
    func mb_distanceTest() {
        // 测试网站https://www.hhlink.com/经纬度/
        MBLog("\(MBDistance.calculate(begin: MBCoordination.init(lon: -1, lat: 0), to: MBCoordination.init(lon: 1, lat: 0)))")   //  222389.85328911748
        MBLog("\(MBDistance.calculate(begin: MBCoordination.init(lon: 1, lat: 0), to: MBCoordination.init(lon: -1, lat: 0)))")  //  222389.85328911748
        MBLog("\(MBDistance.calculate(begin: MBCoordination.init(lon: 180, lat: 0), to: MBCoordination.init(lon: -180, lat: 0)))")  //  1.5604449514735575e-09
        MBLog("\(MBDistance.calculate(begin:MBCoordination.init(lon: 50, lat: 0), to: MBCoordination.init(lon: 90, lat: 50)))")   //  6727437.14492318
    }
}
