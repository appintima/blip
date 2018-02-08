//
//  SellVC+.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-19.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Firebase
import Lottie
import CoreLocation
import Material
import FBSDKLoginKit
import Mapbox
import PopupDialog
import Alamofire
import Stripe
import SHSearchBar
import Kingfisher
import NotificationBannerSwift


extension SellVC: Constrainable{
    
    ///////////////////////// Functions that enable stripe payments go here /////////////////////////////
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print(error)
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        let source = paymentResult.source.stripeID
        MyAPIClient.sharedClient.addPaymentSource(id: source, completion: { (error) in })
    }
    
    
    func prepareBannerForJobAccepted(user: IntimaUser, job: Job){
        
        let profilePicture = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        profilePicture.ApplyOuterShadowToView()
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.kf.setImage(with: user.photoURL)
        let banner = NotificationBanner(title: "Job Accepted", subtitle: "\(user.name!) has accepted your job", leftView: profilePicture, style: .info)
        banner.show(bannerPosition: .bottom)
        banner.autoDismiss = true
    }
    
    func popupForNoInternet()-> PopupDialog {
        let title = "Internet Unavailable"
        let message = "Please connect to the internet and try again"
        let okButton = CancelButton(title: "OK") {
            return
        }
        let popup = PopupDialog(title: title, message: message)
        popup.addButton(okButton)
        return popup
    }
    
    func centerCameraOnJobAccepter(location: CLLocationCoordinate2D){
        
        self.camera.altitude = CLLocationDistance(100000)
        self.camera.centerCoordinate = location
        self.camera.pitch = CGFloat(0)
        self.MapView.setCamera(camera, withDuration: 2, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)) {
            self.camera.altitude = CLLocationDistance(3000)
            self.camera.pitch = CGFloat(60)
            self.MapView.setCamera(self.camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    //Prepares the map by adding annotations for jobs from firebase, and setting the mapview.
    @objc func prepareMap(){
        
        
        
        service.checkUserStatus { (code) in
            if code == 0{
                
                self.service.getJobsFromFirebase(MapView: self.MapView) { annotationDict  in
                    self.allAnnotations = annotationDict
                }
            }
            else if code == 6{
                
                self.service.getJobAcceptedByCurrentUser(completion: { (job) in
                    self.acceptedJob = job
                    self.performSegue(withIdentifier: "endJobFromSellVC", sender: self)
                })
                
            }

            else if code == 7{
                
                self.service.getJobAcceptedByCurrentUser(completion: { (job) in
                    self.acceptedJob = job
                    self.performSegue(withIdentifier: "startJobFromSellVC", sender: self)
                })
                
            }
                
            else if code == 8{
                
                self.service.getJobAcceptedByCurrentUser(completion: { (job) in
                    self.acceptedJob = job
                    self.performSegue(withIdentifier: "goToStartJob", sender: self)
                })
                
            }
            
            else if code == 2{
                
                self.setStateOnJobStart()
            }
            
            else if code == 3{
                
                self.setStateWhenAccepterIsReady()
            }
            
            else if code == 4{
                
                self.setStateForJobWasAccepted()
            }
            
            else if code == 1{
                
                self.setStateOnJobEnd()
            }
        }
        
        service.setAppState { (code, jobObject) in
            
            if let stateCode = code{
                
                if stateCode == 1{
                    
                    self.setStateOnJobStart()
                }
                
                else if stateCode == 4{
                    
                    self.setStateWhenAccepterIsReady()
                }
                
                else if stateCode == 5{
                    
                    self.setStateOnJobEnd()
                }
                
                else if stateCode == 3{
                    
                    self.setStateForJobWasAccepted()
                }
            }
            
            else{
                
                if let task = jobObject{
                    if let anno = self.allAnnotations[task.jobID]{
                        self.MapView.removeAnnotation(anno)
                    }
                }
            }
        }
    }
    
    
    func setStateForJobWasAccepted(){
        
        self.service.GetUserHashWhoAccepted { (hash) in
            
            self.service.getUserInfo(hash: hash, completion: { (userObject) in
                if let user = userObject{
                    self.accepterUserObject = user
                    self.service.getJobPostedByCurrentUser(completion: { (jobPost) in
                        self.currentJobPost = jobPost
                        self.prepareBannerForJobAccepted(user: user, job: jobPost)
                        if let annotations = self.MapView.annotations{
                            self.MapView.removeAnnotations(annotations)
                        }
                        self.accepterHash = hash
                        self.service.getLiveLocationOnce(hash: hash, completion: { (loc) in
                            self.jobAccepterAnnotation.photoURL = user.photoURL
                            self.MapView.addAnnotation(self.jobAccepterAnnotation)
                            self.jobAccepterAnnotation.coordinate = loc
                            self.centerCameraOnJobAccepter(location: loc)
                            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateAccepterLocations), userInfo: nil, repeats: true)
                        })
                    })
                }
            })
        }
    }
    
    func setStateWhenAccepterIsReady(){
        
        if let accepter = self.accepterUserObject{
            let profilePicture = UIImageView()
            profilePicture.kf.setImage(with: accepter.photoURL)
            let banner = NotificationBanner(title: "\(accepter.name!) is ready", subtitle: "Tap here to begin the job", leftView: profilePicture, style: .info)
            banner.show()
            
            banner.autoDismiss = false
            banner.dismissOnTap = false
            banner.dismissOnSwipeUp = false
            banner.onTap = {
                
                banner.dismiss()
                self.service.ownerReady(job: self.currentJobPost!, completion: { (accepterDeviceToken) in
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
                    
                })
            }
        }
        
        else{
            
            self.service.GetUserHashWhoAccepted { (hash) in
                
                self.service.getUserInfo(hash: hash, completion: { (userObject) in
                    if let user = userObject{
                        self.accepterUserObject = user
                        self.service.getJobPostedByCurrentUser(completion: { (jobPost) in
                            self.currentJobPost = jobPost
                            self.prepareBannerForJobAccepted(user: user, job: jobPost)
                            if let annotations = self.MapView.annotations{
                                self.MapView.removeAnnotations(annotations)
                            }
                            self.accepterHash = hash
                            self.service.getLiveLocationOnce(hash: hash, completion: { (loc) in
                                self.jobAccepterAnnotation.photoURL = user.photoURL
                                self.MapView.addAnnotation(self.jobAccepterAnnotation)
                                self.jobAccepterAnnotation.coordinate = loc
                                self.centerCameraOnJobAccepter(location: loc)
                                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateAccepterLocations), userInfo: nil, repeats: true)
                                self.setStateWhenAccepterIsReady()
                            })
                        })
                    }
                })
            }
            
        }
    }


    
    func setStateOnJobStart(){
        
        let newCheck = LOTAnimationView(name: "check")
        let banner = NotificationBanner(title: "Success", subtitle: "The job has begun", leftView: newCheck, style: .info)
        newCheck.play()
        banner.show()
        banner.dismissOnSwipeUp = false
        banner.dismissOnTap = false
        banner.autoDismiss = true
        UIView.animate(withDuration: 1.5, animations: {
            self.searchBar.alpha = 0
            self.postJobButton.alpha = 0
        })
    }
    
    func setStateOnJobEnd(){
        
        let check = LOTAnimationView(name: "check")
        let banner = NotificationBanner(title: "Job completion", subtitle: "Tap here to confirm payment", leftView: check, style: .info)
        check.play()
        banner.show()
        banner.dismissOnTap = false
        banner.autoDismiss = false
        banner.onTap = {
            
            banner.dismiss()
            self.prepareAndAddBlurredLoader()
            
            self.service.getJobPostedByCurrentUser(completion: { (job) in
                MyAPIClient.sharedClient.completeCharge(job: job, completion: { (id) in
                    
                    self.removedBlurredLoader()
                    if id != nil{
                        self.service.confirmedJobEnd()
                        banner.dismiss()
                        UIView.animate(withDuration: 1.5, animations: {
                            
                            self.searchBar.alpha = 1
                            self.postJobButton.alpha = 1
                        })
                        UIView.animate(withDuration: 1, animations: {
                            
                            self.MapView.removeAnnotation(self.jobAccepterAnnotation)
                            self.service.getJobsFromFirebase(MapView: self.MapView) { annotationDict  in
                                self.allAnnotations = annotationDict
                            }
                        })
                        
                        
                    }
                    else{
                        let errorPopup = PopupDialog(title: "Error", message: "Could not process the payment, please try again or add a new payment method")
                        self.present(errorPopup, animated: true, completion: nil)
                        banner.show()
                    }
                })
            })
        }
    }
    
    @objc func updateAccepterLocations(){
        
        service.getLiveLocation(hash: self.accepterHash!) { (location) in
            self.camera.centerCoordinate = location
            self.jobAccepterAnnotation.coordinate = location
        }
    }
    
    func prepareSearchBar(){
        
        let searchGlassIconTemplate = UIImage(named: "icon-search")!.withRenderingMode(.alwaysTemplate)
        let leftView1 = imageViewWithIcon(searchGlassIconTemplate, rasterSize: rasterSize)
        searchBar = defaultSearchBar(withRasterSize: rasterSize, leftView: leftView1, rightView: nil, delegate: self)
        view.addSubview(searchBar)
        self.setupLayoutConstraints()
        
    }
    
    /**
     
     */
    func prepareBannerLeftView(){
        
        postedJobAnimation.handledAnimation(Animation: self.check)
    }
    
    //Prepares a banner for when a job has been successfully posted and paid for
    func prepareBannerForPost() {
        
        let banner = NotificationBanner(title: "Success", subtitle: "Your job was posted", leftView: postedJobAnimation, style: .success)
        banner.show()
        banner.dismissOnSwipeUp = true
        banner.dismissOnTap = true
        check.play()
        
    }
    
    // Constrainable Protocol
    func setupLayoutConstraints() {
        let searchbarHeight: CGFloat = 44.0
        
        // Deactivate old constraints
        viewConstraints?.forEach { $0.isActive = false }
        
        let constraints = [
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            searchBar.leadingAnchor.constraint(equalTo:
                view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            searchBar.heightAnchor.constraint(equalToConstant: searchbarHeight),
            ]
        
        NSLayoutConstraint.activate(constraints)
        
        if viewConstraints != nil {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
        
        viewConstraints = constraints
    }
    
    
    //Any adjustments to job form visuals should be done here.
    func prepareJobForm() {
        self.jobDetailsView.cornerRadius = 7
        self.jobPriceView.cornerRadius = 7
    }
    
}







// MARK: - Helper Functions (GLOBAL)
func defaultSearchBar(withRasterSize rasterSize: CGFloat, leftView: UIView?, rightView: UIView?, delegate: SHSearchBarDelegate, useCancelButton: Bool = false) -> SHSearchBar {
    var config = defaultSearchBarConfig(rasterSize)
    config.leftView = leftView
    config.rightView = rightView
    config.useCancelButton = useCancelButton
    
    if leftView != nil {
        config.leftViewMode = .always
    }
    
    if rightView != nil {
        config.rightViewMode = .unlessEditing
    }
    
    let bar = SHSearchBar(config: config)
    bar.delegate = delegate
    bar.placeholder = NSLocalizedString("Filter Jobs", comment: "")
    bar.updateBackgroundImage(withRadius: 6, corners: [.allCorners], color: UIColor.white)
    bar.layer.shadowColor = UIColor.black.cgColor
    bar.layer.shadowOffset = CGSize(width: 0, height: 3)
    bar.layer.shadowRadius = 5
    bar.layer.shadowOpacity = 0.25
    return bar
}

func defaultSearchBarConfig(_ rasterSize: CGFloat) -> SHSearchBarConfig {
    var config: SHSearchBarConfig = SHSearchBarConfig()
    config.rasterSize = rasterSize
    config.textAttributes = [.foregroundColor : UIColor.gray]
    return config
}

func imageViewWithIcon(_ icon: UIImage, rasterSize: CGFloat) -> UIImageView {
    let imgView = UIImageView(image: icon)
    imgView.frame = CGRect(x: 0, y: 0, width: icon.size.width + rasterSize * 2.0, height: icon.size.height)
    imgView.contentMode = .center
    imgView.tintColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
    return imgView
}
