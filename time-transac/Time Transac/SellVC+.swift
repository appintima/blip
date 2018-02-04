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
    
    func prepareBannerForJobStarted(){
        
        
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
                // Nothing happening
            }
            else if code == 1{
                // segue him back into the navigation controller
            }
            else if code == 2{
                if let allAnnos = self.MapView.annotations{
                    self.MapView.removeAnnotations(allAnnos)
                }
            }
        }
        
        self.service.getJobsFromFirebase(MapView: self.MapView) { annotationDict  in
            self.allAnnotations = annotationDict
        }
        
        self.service.checkJobAcceptedStatus { (code, hash) in
            if code == 1{
                // Make sure he is in startJobNavigation, but dont segue because there might be two different segues happning at same time
            }
            else if code == 2{
                
                self.service.getUserInfo(hash: hash!, completion: { (userObject) in
                    if let user = userObject{
                        self.accepterUserObject = user
                        self.service.getJobPostedByCurrentUser(completion: { (jobPost) in
                            self.currentJobPost = jobPost
                            self.prepareBannerForJobAccepted(user: user, job: jobPost)
                            if let annotations = self.MapView.annotations{
                                self.MapView.removeAnnotations(annotations)
                            }
                            self.accepterHash = hash
                            self.service.getLiveLocationOnce(hash: hash!, completion: { (loc) in
                                self.jobAccepterAnnotation.photoURL = user.photoURL
                                self.MapView.addAnnotation(self.jobAccepterAnnotation)
                                self.jobAccepterAnnotation.coordinate = loc
                                self.centerCameraOnJobAccepter(location: loc)
                                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateAccepterLocations), userInfo: nil, repeats: true)
                            })
                        })
                    }
                    else{
                        
                        let errorPopup = PopupDialog(title: "Error", message: "Could not get job accepter's information from the database")
                        self.present(errorPopup, animated: true, completion: nil)
                    }
                })
            }
        }
        
        service.removeAcceptedJobsFromMap { (job) in
            
            if let task = job{
                if let anno = self.allAnnotations[task.jobID]{
                    self.MapView.removeAnnotation(anno)
                }
            }
        }
        
        service.onAccepterPressedReady { (code) in
            if code == 0{
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
                
            }
        }
        
        service.onJobBegun { (code) in
            
            if code == 0{
                let newCheck = LOTAnimationView(name: "check")
                let banner = NotificationBanner(title: "Job begun", subtitle: "Your assigned job has begun", leftView: newCheck, style: .info)
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







// MARK: - Helper Functions
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
