//
//  CustomTableViewCell.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-06.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//
import UIKit
import Material
import Firebase
import Lottie

class JobCandidate: UIView {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var fullNameLabel: UILabel!

    let ratingAnimation = LOTAnimationView(name: "5_stars")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePic.cornerRadius = profilePic.frame.height/2
        ratingsView.handledAnimation(Animation: ratingAnimation)
    }


    func setRating(rating: CGFloat){
        ratingAnimation.play(toProgress: CGFloat(rating/5), withCompletion: nil)

    }
    
}
