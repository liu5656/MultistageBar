//
//  MBLocationViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/12.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
import MapKit

class MBLocationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        LocationManager.shared.startUpdatingLocation { (location, province, city) in
            MBLog("longitude:\(location?.coordinate.longitude) latitude:\(location?.coordinate.latitude) altitude:\(location?.altitude) province: \(province) city: \(city)")
        }
        _ = mapV
        
        MBCitySelector.mb_show { (pro, cit, cou) in
            MBLog("\(pro) \(cit) \(cou)")
        }
    }
    
    lazy var mapV: MKMapView = {
        let map = MKMapView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 300))
        map.setUserTrackingMode(.follow, animated: true)
        view.addSubview(map)
        return map
    }()
    
//    lazy var citySelector: MBCitySelector = {
//        let temp = MBCitySelector.init()
//        temp.frame = CGRect.init(x: 0, y: 300, width: Screen.width, height: 300)
//        view.addSubview(temp)
//        return temp
//    }()
    
    
}
