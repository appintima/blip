//
//  JobOwnerStartJob.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 1/31/18.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Material
import Firebase
import Alamofire
import PopupDialog
import Pastel

class JobOwnerStartJob: UIViewController {

    @IBOutlet var gradientView: PastelView!
    
    @IBOutlet weak var StartJob: RaisedButton!
    let service = ServiceCalls()
    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func StartJobPressed(_ sender: Any) {

        self.service.checkIfAccepterReady { (code) in
            
            if code == 1{
                self.service.ownerReady(job: self.job, completion: { (accepterDeviceToken) in
                    let title = "Intima"
                    let displayName = (Auth.auth().currentUser?.displayName)!
                    let body = "\(displayName) is ready for you to start the job"
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
                    self.performSegue(withIdentifier: "goToEndJob", sender: self
                    )
                })
            }
            else{
                let errorPopup = PopupDialog(title: "Error", message: "The job accepter has not pressed start job yet")
                self.present(errorPopup, animated: true, completion: nil)
            }
        }
        
    }
    

}
