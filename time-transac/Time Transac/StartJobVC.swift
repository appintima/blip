//
//  StartJobVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 2018-01-02.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Pastel
import Firebase
import Alamofire

class StartJobVC: UIViewController {

    var service:ServiceCalls{
        return ServiceCalls()
    }
    var job:Job!
    
    @IBOutlet var gradientView: PastelView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startPressed(){
        if self.service.emailHash != job.jobOwnerEmailHash{// accepter pressed start
            service.accepterReady(job: self.job, completion: { (ownerDeviceToken) in
                //Send notification to owner
                let title = "Intima"
                let displayName = (Auth.auth().currentUser?.displayName)!
                let body = "\(displayName) is ready to begin your task"
                let device = ownerDeviceToken!
                var headers: HTTPHeaders = HTTPHeaders()
                headers = ["Content-Type":"application/json", "Authorization":"key=\(AppDelegate.SERVERKEY)"]
                
                let notification = ["to":"\(device)", "notification":["body":body, "title":title, "badge":1, "sound":"default"]] as [String : Any]
                
                Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                    
                    if let err = response.error{
                        print(err.localizedDescription)
                    }
                    
                })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accepterReadyNotification"), object: nil)

            })
        }else{// owner is ready for job to start
            self.service.ownerReady(job: self.job, completion: { (accepterDeviceToken) in
                let title = "Intima"
                let displayName = (Auth.auth().currentUser?.displayName)!
                let body = "\(displayName) is ready for you to start your task"
                let device = accepterDeviceToken!
                var headers: HTTPHeaders = HTTPHeaders()
                headers = ["Content-Type":"application/json", "Authorization":"key=\(AppDelegate.SERVERKEY)"]
                
                let notification = ["to":"\(device)", "notification":["body":body, "title":title, "badge":1, "sound":"default"]] as [String : Any]
                
                Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                    
                    if let err = response.error{
                        print(err.localizedDescription)
                    }
                    
                })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ownerReadyNotification"), object: nil)
            })
        }
    }

}
