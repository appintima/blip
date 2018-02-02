//
//  DataBase.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-22.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation
import Firebase
import Mapbox

class ServiceCalls{

    private var fireBaseRef: DatabaseReference!
    let jobsRef: DatabaseReference!
    let userRef: DatabaseReference!
    var availableJobs: [Job] = []
    let helper = HelperFunctions()
    let emailHash = HelperFunctions().MD5(string: (Auth.auth().currentUser?.email)!)
    var jobsRefHandle:DatabaseHandle!
    var userRefHandle: DatabaseHandle!
    var newHandle: DatabaseHandle!
    var childHandle: DatabaseHandle!
    static var counter = 0
    
    init() {
        fireBaseRef = Database.database().reference()
        jobsRef = fireBaseRef.child("AllJobs")
        userRef = fireBaseRef.child("Users")
    }
    
/**
     Add a job to Firebase Database
 */
    
    func addJobToFirebase(jobTitle: String, jobDetails: String, pricePerHour: String, numberOfHours: String, locationCoord: CLLocationCoordinate2D, chargeID: String){
        
        let user = Auth.auth().currentUser
        let newJobID = self.jobsRef.childByAutoId().key
        let latitude = locationCoord.latitude
        let longitude = locationCoord.longitude
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let fullDate = "\(day)-\(month)-\(year) \(hour):\(minute):\(second)"
        
        let jobDict: [String:Any] = ["latitude":latitude, "longitude":longitude, "JobOwner":self.emailHash, "JobTitle":jobTitle, "JobDescription":jobDetails, "Price":pricePerHour, "Time":numberOfHours, "isOccupied":false, "isCompleted":false, "started":false, "Full Name":(user?.displayName)!, "accepterReady": false]
        
        
        // adding job to the user who posted list of last post
        let lastPostedRef = self.userRef.child(self.emailHash).child("LastPost")
        
        self.jobsRef.child(newJobID).updateChildValues(jobDict)
        lastPostedRef.setValue(newJobID)
        
        //add charges to user reference
        let userChargesRef = self.userRef.child(self.emailHash).child("Charges")
        let keyByDate = chargeID
        userChargesRef.child(keyByDate).child("Time").setValue(fullDate)
        userChargesRef.child(keyByDate).child(newJobID).updateChildValues(jobDict)
        
    }
    
    func getUserInfo(hash: String, completion: @escaping (IntimaUser?) -> ()){
        
        userRef.child(hash).observeSingleEvent(of: .value) { (userSnap) in
            let user = IntimaUser(snapshot: userSnap)
            completion(user)
        }
    }
    
    

    func removedJobFromFirebase(completion: @escaping (Job?)->()){

        jobsRefHandle = jobsRef.observe(.childRemoved, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            completion(job)
        })

    }

    func removeAcceptedJobsFromMap(completion: @escaping (Job?)->()){

        jobsRefHandle = jobsRef.observe(.childChanged, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            // if the task is accepted but not completed put the job in completion to be removed when called
            if ((job?.occupied)! && !((job?.completed)!) && (job?.jobOwnerEmailHash != self.emailHash)){
                print("Inside")
                completion(job)
            }
        })
        
    }
    
/**
     doesn't load tasks whose occupied is true as part of completion dictionary
 */
    
    func getJobsFromFirebase(MapView:MGLMapView , completion: @escaping ([String:CustomMGLAnnotation])->()){

//        var newJobs : [Job] = []
        var annotationDict: [String:CustomMGLAnnotation] = [:]
        
        jobsRefHandle = jobsRef.observe(.childAdded, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            // check if the curr job snap is not curr user's and also if the job is not accepted
            if (job?.jobOwnerEmailHash != self.emailHash && !(job?.occupied)!){
                
                let jobPosterRef = self.userRef.child((job?.jobOwnerEmailHash)!)
                jobPosterRef.observeSingleEvent(of: .value, with: { (snapshot2) in
                    let userVal = snapshot2.value as? [String:AnyObject]
                    job?.jobOwnerRating = userVal!["Rating"] as? Float
                    job?.jobOwnerPhotoURL = URL(string: (userVal!["photoURL"] as? String)!)
                    
                    let point = CustomMGLAnnotation()
                    point.job = job
                    point.coordinate = (job?.location.coordinate)!
                    point.title = job?.title
                    point.subtitle = ("$"+"\((job?.wage_per_hour)!)"+"/Hour")
                    point.photoURL = job?.jobOwnerPhotoURL
                    MapView.addAnnotation(point)
                    annotationDict[(job?.jobID)!] = point
                    completion(annotationDict)
                })
            }
        })

    }
    
    func startJobPressedByAccepter(job: Job, completion: @escaping(String) -> ()){
        
        jobsRef.child(job.jobID).updateChildValues(["accepterHasBegun": true, "jobHasBegun": false])
    }

    
/**
    When you accept a job, a device token is stored for notification.
     
     - parameter job: The job being accepted.
     - parameter user: The user who accepted the job.
     - parameter completion: The completion block where device token is stored.
     - returns: Void
*/
    func acceptPressed(job: Job, user: User, completion: @escaping (String)->()){
        
        
        let userAcceptedRef = self.userRef.child(self.emailHash).child("AcceptedJobs")

        
        let jobDict: [String:Any] = ["latitude":job.latitude, "longitude":job.longitude, "JobOwner":job.jobOwnerEmailHash, "JobTitle":job.title, "JobDescription":job.description, "Price":"\(job.wage_per_hour)", "Time":"\(job.maxTime)", "isOccupied":job.occupied!, "isCompleted":job.completed!,
                                     "Full Name":(job.jobOwnerFullName)!]

        userAcceptedRef.child(job.jobID).updateChildValues(jobDict)
        
        jobsRef.child(job.jobID).updateChildValues(["isOccupied":true, "isAcceptedBy": self.helper.MD5(string: user.email!)])

        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userValues = snapshot.value as! [String : AnyObject]
            
            // add the job to job poster's "LatestPostAccepted" reference in database
            self.userRef.child(job.jobOwnerEmailHash).child("LatestPostAccepted").setValue(self.emailHash)
            //add to the "uAccepted" ref for current user
            self.userRef.child(self.helper.MD5(string: user.email!)).child("uAccepted").setValue(job.jobOwnerEmailHash)
            guard let deviceToken = userValues[job.jobOwnerEmailHash]!["currentDevice"]! as? String else{return}
            completion(deviceToken)
        })
    }

    
/**
 
 */
    
    func getCustomerID(completion: @escaping (String) -> ()){
        
        userRef.observe(.value, with: { (snapshot) in
            let userDict = snapshot.value as! [String: AnyObject]
            let customer = userDict[self.emailHash]!["customer_id"]! as! String
            completion(customer)
            self.userRef.removeAllObservers()
        })
    }
    
    func checkUserStatus(completion: @escaping(Int?) -> ()){
        
        userRefHandle = userRef.child(emailHash).observe(.value, with: { (status) in
            if status.hasChild("LatestPostAccepted"){
                completion(2) // Code 2 if the current user's job has been accepted by someone
            }
            else if (status.hasChild("uAccepted")){
                completion(1) // Code 1 if the current user accepted someone elses job
            }
            else{
                completion(0) // if the current user is just a user who didnt accept a job or hasnt has his job accepted
            }
        })
        
    }
    
    
/**
     check if the current user needs make actions on tasks
 */
    
    func checkJobAcceptedStatus(completion: @escaping (Int?, String?) -> ()){
        
        userRef.child(emailHash).observe(.childAdded, with: { (userSnap) in
            let key = userSnap.key
            if key == "uAccepted"{// priority
                print("You accepted a job")
                completion(1, (userSnap.value as! String))// Means that current user accepted a job
            }
            else if key == "LatestPostAccepted"{
                print("Your job got accepted")
                completion(2, (userSnap.value as! String))// Means that current user's job got accepted
            }else{
                print("Something else got added")
                completion(0, nil)// Means nothing happened
            }

        })
    }
    
    
    func updateJobAccepterLocation(location: CLLocationCoordinate2D){
        userRef.child(self.emailHash).updateChildValues(["currentLatitude": location.latitude, "currentLongitude": location.longitude])
        
    }
    
    func getLiveLocationOnce(hash: String, completion: @escaping (CLLocationCoordinate2D) -> ()){
        
        userRef.child(hash).observeSingleEvent(of: .value) { (userSnap) in
            print("entered get live locations")
            let value = userSnap.value as? [String: AnyObject]
            let lat = value!["currentLatitude"] as? Double
            let long = value!["currentLongitude"] as? Double
            completion(CLLocationCoordinate2D(latitude: lat!, longitude: long!))
        }
    }
    
    func getLiveLocation(hash: String, completion: @escaping (CLLocationCoordinate2D) -> ()){
        
        userRefHandle = userRef.child(hash).observe(.value, with: { (userSnap) in
            print("entered get live locations")
            let value = userSnap.value as? [String: AnyObject]
            let lat = value!["currentLatitude"] as? Double
            let long = value!["currentLongitude"] as? Double
            completion(CLLocationCoordinate2D(latitude: lat!, longitude: long!))
        })
    }
    
    
    //start job pressed
    func setJobStarted(job:Job){
        jobsRef.child(job.jobID).updateChildValues(["started":true])
    }
    
    //start job pressed by accepter
    func accepterReady(job:Job, completion: @escaping (String?)->()){
        jobsRef.child(job.jobID).updateChildValues(["accepterReady":true])
        userRef.child(job.jobOwnerEmailHash).observeSingleEvent(of: .value) { (snapshot) in
            if let user = snapshot.value as? [String: AnyObject]{
                let currentDevice = user["currentDevice"] as? String
                completion(currentDevice)
            }
        }
    }
    
    //start job pressed by poster
    func ownerReady(job:Job, completion: @escaping (String?)->()){
        jobsRef.child(job.jobID).updateChildValues(["ownerReady":true])
        jobsRef.child(job.jobID).updateChildValues(["started":true])
        if let accepterHash = jobsRef.child(job.jobID).value(forKey: "isAcceptedBy") as? String{
            print("HERE IS ACCEPTER ", accepterHash)
            if let accepterDevice = userRef.child(accepterHash).value(forKey: "currentDevice") as? String{
                completion(accepterDevice)
            }
        }else{
            print("NO ACCEPTER HASH")
        }
    }
    
    func getJobPostedByCurrentUser(completion: @escaping(Job) -> ()){
        
        userRef.child(emailHash).observeSingleEvent(of: .value) { (user) in
            
            let lastPostSnapshot = user.childSnapshot(forPath: "LastPost")
            if let lastPost = lastPostSnapshot.value as? String{
                self.jobsRef.child(lastPost).observeSingleEvent(of: .value) { (snapshot) in
                    let job = Job(snapshot: snapshot)
                    completion(job!)
                }
            }
        }
    }
    
    func checkIfAccepterReady(completion: @escaping(Int) -> ()){
        
        getJobPostedByCurrentUser { (job) in
            
            self.jobsRef.child(job.jobID).observe(.value, with: { (snapshot) in
            
                let job = Job(snapshot: snapshot)
                if (job?.accepterReady)!{
                    completion(1) // Code 1 means that the accepter is ready
                }
                else{
                    completion(2) // Accepter isnt ready
                }
            })
        }
    }
    
}









