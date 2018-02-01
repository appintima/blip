//
//  TabsController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 8/8/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import CoreLocation


class ApplicationTabsController: UITabBarController, CLLocationManagerDelegate {

    let coreLocation = CLLocationManager()
    var currentLocation: CLLocation!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        coreLocation.delegate = self
        coreLocation.desiredAccuracy = kCLLocationAccuracyBest
        coreLocation.requestWhenInUseAuthorization()
        coreLocation.requestLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            coreLocation.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            self.currentLocation = location
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
