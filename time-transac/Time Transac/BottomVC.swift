//
//  ScrollViewController.swift
//  ISHPullUpSample
//
//  Created by Felix Lamouroux on 25.06.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

import UIKit
import ISHPullUp
import Material
import Stripe
import Kingfisher

class BottomVC: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate {
    
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet weak var acceptedJobView: UIView!
    
    private let service = ServiceCalls()
    private var firstAppearanceCompleted = false
    weak var pullUpController: ISHPullUpViewController!
    private var pullupWasClosed = true
    var jobAccepter: IntimaUser?
    
    // we allow the pullUp to snap to the half way point
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedJobView.ApplyOuterShadowToView()
        let tapOnAccepted = UITapGestureRecognizer(target: self, action: #selector(tappedOnAcceptedJobView(_sender:)))
        self.acceptedJobView.addGestureRecognizer(tapOnAccepted)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true;
        updatePullUp()
    }
    
    
    // MARK: ISHPullUpSizingDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        
        let totalHeight = rootView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        // we allow the pullUp to snap to the half way point
        // we "calculate" the cached value here
        // and perform the snapping in ..targetHeightForBottomViewController..
        return totalHeight
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        return 100
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        
        if pullupWasClosed{
            return self.rootView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        }
            
        else{
            return 100
        }
        
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController bottomVC: UIViewController) {
        // we update the scroll view's content inset
        // to properly support scrolling in the intermediate states
        //        scrollView.contentInset = edgeInsets;
    }
    
    // MARK: ISHPullUpStateDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        
        if state == .collapsed{
            self.pullupWasClosed = true
        }
        
        if state == .expanded{
            self.pullupWasClosed = false
        }
        //        // Hide the scrollview in the collapsed state to avoid collision
        //        // with the soft home button on iPhone X
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.rootView.alpha = (state == .collapsed) ? 0.25 : 1;
        }
    }
    
    func updatePullUp(){
        
        service.checkJobAcceptedStatus { (code, hash) in
            if code == 2{
                
                let customAcceptedJobView = Bundle.main.loadNibNamed("JobCandidate", owner: self, options: nil)?.first as! JobCandidate
                customAcceptedJobView.tag = 101
                self.service.getUserInfo(hash: hash!, completion: { (user) in
                    customAcceptedJobView.fullNameLabel.text = user?.name
                    customAcceptedJobView.profilePic.kf.setImage(with: user?.photoURL)
                    customAcceptedJobView.setRating(rating: (user?.rating)!)
                    self.jobAccepter = user
                    self.acceptedJobView.addSubview(customAcceptedJobView)
                })
            }
        }
    }
    
    //TODO:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails"{
            let dest = segue.destination as! ConfirmProfilePageVC
            if let user = self.jobAccepter{
                dest.jobAccepter = user
            }
        }
    }
    
    @objc
    func tappedOnAcceptedJobView(_sender: UITapGestureRecognizer){
        
        let subViews = self.acceptedJobView.subviews
        for view in subViews{
            
            if view.tag == 101{
                self.performSegue(withIdentifier: "goToDetails", sender: self)
            }
        }
        
    }
    
}

