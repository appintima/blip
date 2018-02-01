//
//  Job.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-14.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase


class Job{
    
    var jobOwnerPhotoURL: URL?
    let description: String
    var title: String
    var wage_per_hour: Double
    var maxTime: Double
    var jobOwner: User!
    var jobApplicant: User!
    var occupied: Bool!
    var started:Bool!
    var completed: Bool!
    var jobID: String!
    var location: CLLocation!
//    static var jobIDarray = [String]()
    var jobTakerID: String!
    var jobOwnerEmailHash: String!
    var jobOwnerFullName: String!
    var jobOwnerRating: Float?
    var ref: DatabaseReference!
    var latitude: Double!
    var longitude: Double!
    var accepterReady: Bool!



    init?(snapshot: DataSnapshot) {
        guard !snapshot.key.isEmpty,
            let jobValues = snapshot.value as? [String:AnyObject],
            let latitude = jobValues["latitude"] as? Double,
            let longitude = jobValues["longitude"] as? Double,
            let occupied = jobValues["isOccupied"] as? Bool,
            let completed = jobValues["isCompleted"] as? Bool,
            let started = jobValues["started"] as? Bool,
            let title = jobValues["JobTitle"] as? String,
            let description = jobValues["JobDescription"] as? String,
            let jobOwnerEmailHash = jobValues["JobOwner"] as? String,
            let jobOwnerFullName = jobValues["Full Name"] as? String,
            let wage_per_hour = jobValues["Price"] as? String,
            let maxTime = jobValues["Time"] as? String,
            let accepterReady = jobValues["accepterReady"] as? Bool
        else{return nil}
            
        
        
        
        self.ref = snapshot.ref
        self.jobID = snapshot.key
        self.latitude = latitude
        self.longitude = longitude
        
        self.occupied = occupied
        self.completed = completed
        self.started = started
        self.accepterReady = accepterReady
        self.title = title
        self.description = description
        self.jobOwnerEmailHash = jobOwnerEmailHash
        self.jobOwnerFullName = jobOwnerFullName
        self.wage_per_hour = Double(wage_per_hour)!
        self.maxTime = Double(maxTime)!
        self.location = CLLocation(latitude: latitude, longitude: longitude)

    }
    

    func setOccupied(){
        self.occupied = true
        ref.updateChildValues(["isOccupied" : true])
    }
    
    func setNotOccupied(){
        self.occupied = false
        ref.updateChildValues(["isOccupied" : false])
    }
    
    func setCompleted(){
        ref.updateChildValues(["isCompleted" : true])
    }
    
    func setNotCompleted(){
        ref.updateChildValues(["isCompleted" : false])
    }
    

}











