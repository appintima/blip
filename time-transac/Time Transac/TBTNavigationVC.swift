//
//  TBTNavigationVC.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-02-02.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation

class TBTNavigationVC: NavigationViewController, NavigationViewControllerDelegate, CLLocationManagerDelegate {
    var job: Job!
    var locationManager = CLLocationManager()
    let service = ServiceCalls()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        useCurrentLocations()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateAccepterLocation), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func useCurrentLocations(){
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let startActualJobVC = sb.instantiateViewController(withIdentifier: "endJobNavigation") as? endJobNavigation
        if let job = self.job{
            startActualJobVC?.job = job
        }
        self.locationManager.stopUpdatingLocation()
        self.timer.invalidate()
        self.present(startActualJobVC!, animated: true, completion: nil)
        
        return true
    }

    
    @objc func updateAccepterLocation(){
        
        print("Entered here")
        if let location = self.locationManager.location?.coordinate{
            service.updateJobAccepterLocation(location: location)
        }
    }

}
