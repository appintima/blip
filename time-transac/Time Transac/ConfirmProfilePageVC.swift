//
//  ConfirmPageVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 9/23/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//


import UIKit
import Firebase
import Lottie
import Pastel
import Kingfisher
import Alamofire

class ConfirmProfilePageVC: UIViewController {
    
//    var applicantInfo: [String:AnyObject]!
    var currUser: IntimaUser?
    var jobAccepter: IntimaUser?
    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var scrollForReviews: UIScrollView!
    @IBOutlet weak var ratingAnimationView: UIView!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var totalJobs: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var hireButton: UIButton!
    let ratingAnimation = LOTAnimationView(name: "5_stars")
    var picURL: URL?
//    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        prepareInformation()
        self.gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0.7605337501, green: 0.7767006755, blue: 0.7612826824, alpha: 1)])
        profilePic.cornerRadius = profilePic.frame.height/2

        if let jobAccepter = self.jobAccepter{
            picURL = jobAccepter.photoURL
            profilePic.kf.setImage(with: picURL!)
        }else{
            hireButton.isHidden = true
            picURL = currUser!.photoURL
            profilePic.kf.setImage(with: picURL!)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareInformation() {
        if let jobAccepter = self.jobAccepter{
            self.fullNameLabel.text = jobAccepter.name
            self.ratingAnimationView.handledAnimation(Animation: ratingAnimation)
            ratingAnimation.play(toProgress: (jobAccepter.rating)!, withCompletion: nil)
        }else{
            self.fullNameLabel.text = currUser!.name
            self.ratingAnimationView.handledAnimation(Animation: ratingAnimation)
            ratingAnimation.play(toProgress: (currUser?.rating)!, withCompletion: nil)
        }
        
    }
    
    @IBAction func confirmclicked(_ sender: UIButton) {
        let title = "Intima"
//        let body = "Your Job Has Been Accepted By \(Auth.auth().currentUser?.displayName ?? "someone")"
        let body = "You have been awarded the task"
        let device = (jobAccepter?.currentDevice)!
        var headers: HTTPHeaders = HTTPHeaders()
        
        headers = ["Content-Type":"application/json", "Authorization":"key=\(AppDelegate.SERVERKEY)"]
        
        let notification = ["to":"\(device)", "notification":["body":body, "title":title, "badge":1, "sound":"default"]] as [String : Any]
        
        Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
        })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "confirmedNotification"), object: nil)
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
