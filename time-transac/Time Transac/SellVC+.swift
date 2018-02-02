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
    
    
    func prepareBannerForJobAccepted(user: IntimaUser){
        
        let profilePicture = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        profilePicture.cornerRadius = profilePicture.frame.size.height/2
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.kf.setImage(with: user.photoURL)
        let banner = NotificationBanner(title: "Job Accepted", subtitle: "\(user.name!) has accepted your job", leftView: profilePicture, style: .info)
        banner.show(bannerPosition: .bottom)
        banner.autoDismiss = false
        banner.onSwipeUp = {
            self.performSegue(withIdentifier: "goToJobOwnerStartJob", sender: self)
        }
        
    }
    
    func centerCameraOnJobAccepter(location: CLLocationCoordinate2D){
        
        self.camera.altitude = CLLocationDistance(50000)
        self.camera.centerCoordinate = location
        self.camera.pitch = CGFloat(0)
        self.MapView.setCamera(camera, withDuration: 4, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)) {
            self.camera.altitude = CLLocationDistance(11000)
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
            print(annotationDict)
            self.allAnnotations = annotationDict
        }
        
        service.checkJobAcceptedStatus { (code, hash) in
            if code == 1{
                // Make sure he is in startJobNavigation, but dont segue because there might be two different segues happning at same time
            }
            else if code == 2{
                
                self.service.getUserInfo(hash: hash!, completion: { (user) in
                    self.prepareBannerForJobAccepted(user: user!)
                })
                if let annotations = self.MapView.annotations{
                    self.MapView.removeAnnotations(annotations)
                }
                self.accepterHash = hash
                self.service.getLiveLocation(hash: self.accepterHash!, completion: { (loc) in
                    self.jobAccepterAnnotation.coordinate = loc
                    self.centerCameraOnJobAccepter(location: loc)
                    self.service.getUserInfo(hash: self.accepterHash!, completion: { (user) in
                        self.jobAccepterAnnotation.photoURL = user?.photoURL
                        self.MapView.addAnnotation(self.jobAccepterAnnotation)
                    })
                })
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateAccepterLocations), userInfo: nil, repeats: true)
            }
        }
        
        service.removeAcceptedJobsFromMap { (job) in
            
            if let task = job{
                if let anno = self.allAnnotations[task.jobID]{
                    self.MapView.removeAnnotation(anno)
                }
            }
        }
    }

    
    @objc func updateAccepterLocations(){
        
        service.getLiveLocation(hash: self.accepterHash!) { (location) in
            
            UIView.animate(withDuration: 4.5, delay: 0, options: .curveLinear, animations: {
                self.jobAccepterAnnotation.coordinate = location
            }, completion: nil)
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
