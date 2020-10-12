//
//  LocationManager.swift
//  MultistageBar
//
//  Created by x on 2020/10/12.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import MapKit

class LocationManager: NSObject {
    typealias locationCallback = (_ curLocation: CLLocation?, _ province: String?, _ city: String?) -> ()
    @objc static let shared = LocationManager.init()
    private override init(){
        self.locationManager = CLLocationManager.init()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    private var times: Int = 1
    var reverGeocode: Bool = false
    var previousLocation: CLLocation? = nil
    var previousProvince: String? = nil
    var previousCity: String? = nil
    var locationManager: CLLocationManager
    var completionCallback: locationCallback?
    func applyAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    func authorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        }else{
            return CLLocationManager.authorizationStatus()
        }
    }
    func startUpdatingLocation(times: Int = 1, callback: @escaping locationCallback) {
        self.times = times
        self.completionCallback = callback
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }else if status == .notDetermined {
            applyAuthorization()
        }
    }
    func reverseGeocode(location: CLLocation) {
        CLGeocoder.init().reverseGeocodeLocation(location) { (places, err) in
            guard let place = places?.first else {
                self.completionCallback?(self.previousLocation, nil, nil)
                return
            }
            self.previousProvince = place.administrativeArea
            self.previousCity = place.locality
            self.completionCallback?(self.previousLocation, self.previousProvince, self.previousCity)
        }
    }
    func bc_stopLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        guard times > 0 else {
            bc_stopLocation()
            return
        }
        times -= 1
        self.previousLocation = location
        if reverGeocode {
            reverseGeocode(location: location)
        }else{
            completionCallback?(location, nil, nil)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completionCallback?(nil, nil , nil)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

