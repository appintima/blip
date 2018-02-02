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

class TBTNavigationVC: NavigationViewController, NavigationViewControllerDelegate {
    var job: Job!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let startActualJobVC = sb.instantiateViewController(withIdentifier: "endJobNavigation") as? endJobNavigation
        if let job = self.job{
            startActualJobVC?.job = job
        }
        self.present(startActualJobVC!, animated: true, completion: nil)
        return true
    }

}
