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
    
    func setAppState(completion: @escaping(Int?, Job?) -> ()){
        
        
        jobsRef.observe(.childAdded) { (data) in
            
            let dataDict = data.value as? [String: AnyObject]
            let job = Job(snapshot: data)
            
            data.ref.observe(.childAdded, with: { (addedKey) in
                
                
                print(addedKey.key, "This is the added key")
                if (addedKey.key == "isCompleted" && job?.jobOwnerEmailHash == self.emailHash){
                    
                    completion(5, nil) // Current users post was completed
                }
                
                else if (addedKey.key == "started" && dataDict!["isAcceptedBy"] as? String == self.emailHash && !(data.hasChild("isCompleted"))){
                    
                    completion(2, nil) // Job started for the accepter
                }
                    
                else if (addedKey.key == "started" && job?.jobOwnerEmailHash == self.emailHash && !(data.hasChild("isCompleted"))){
                    
                    completion(1, nil) // Code 1 implies that the job has started for poster
                    
                }
                    
                else if (addedKey.key == "accepterReady" && job?.jobOwnerEmailHash == self.emailHash && !(data.hasChild("started"))){
                    
                    completion(4, nil) // Current users post has been accepted and the accepter is ready
                }
                
                else if (addedKey.key == "isAcceptedBy" && job?.jobOwnerEmailHash == self.emailHash && !(data.hasChild("accepterReady"))){
                    
                    completion(3, nil) // Current users post got accepted
                }
                
                
                
                
            })
            
            data.ref.observe(.childRemoved, with: { (removedKey) in
                
                if (removedKey.key == "isAcceptedBy" && job?.jobOwnerEmailHash == self.emailHash){
                    
                    completion(6, nil) // Job was cancelled by the accepter
                }
                
            })
        }
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
        
        let jobDict: [String:Any] = ["latitude":latitude, "longitude":longitude, "jobOwner":self.emailHash, "jobTitle":jobTitle, "jobDescription":jobDetails, "price":pricePerHour, "time":numberOfHours, "fullName":(user?.displayName)!, "charge": chargeID]
        
        
        // adding job to the user who posted list of last post
        let lastPostedRef = self.userRef.child(self.emailHash).child("lastPost")
        
        self.jobsRef.child(newJobID).updateChildValues(jobDict)
        lastPostedRef.setValue(newJobID)
        
        //add charges to user reference
        let userChargesRef = self.userRef.child(self.emailHash).child("Charges")
        let keyByDate = chargeID
        userChargesRef.child(keyByDate).child("Time").setValue(fullDate)
        userChargesRef.child(keyByDate).child(newJobID).updateChildValues(jobDict)
        
    }
    
    func GetUserHashWhoAccepted(completion: @escaping(String) -> ()){
    
        userRef.child(emailHash).observeSingleEvent(of: .value) { (hash) in
            
            if let acceptedHash = hash.value as? [String: AnyObject]{
                
                completion((acceptedHash["latestPostAccepted"] as? String)!)
            }
        }
    }
    
    func getUserInfo(hash: String, completion: @escaping (IntimaUser?) -> ()){
        
        userRef.child(hash).observeSingleEvent(of: .value) { (userSnap) in
            
            if let user = IntimaUser(snapshot: userSnap){
                completion(user)
            }
            else{
                print(userSnap, "couldnt get user info from snapshot")
            }
        }
    }
    
    func getCurrentUserInfo(completion: @escaping(IntimaUser) -> ()){
        
        userRef.child(emailHash).observeSingleEvent(of: .value, with: { (userSnap) in
            
            if let user = IntimaUser(snapshot: userSnap){
                completion(user)
            }
            
            else{
                print(userSnap, "Couldnt get current user info")
            }
        })
    }
    
    func getJobAcceptedByCurrentUser(completion: @escaping(Job?) -> ()){
        
        userRef.child(emailHash).observeSingleEvent(of: .value) { (user) in
        
            let acceptedSnapshot = user.childSnapshot(forPath: "didAccept")
            if let acceptedPost = acceptedSnapshot.value as? String{
                self.jobsRef.child(acceptedPost).observeSingleEvent(of: .value) { (snapshot) in
                    if let job = Job(snapshot: snapshot){
                        completion(job)
                    }
                    else{
                        print("Could not find job")
                    }
                }
            }
        }
    }
    

    func removedJobFromFirebase(completion: @escaping (Job?)->()){

        jobsRefHandle = jobsRef.observe(.childRemoved, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            completion(job)
        })

    }
    
    func getChargeIDFor(job: Job, completion: @escaping(String) ->()){
        
        jobsRef.child(job.jobID).child("charge").observeSingleEvent(of: .value) { (id) in
            if let charge = id.value as? String{
                completion(charge)
            }
        }
    }

    func removeAcceptedJobsFromMap(completion: @escaping (Job?)->()){

        jobsRefHandle = jobsRef.observe(.childChanged, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            // if the task is accepted but not completed put the job in completion to be removed when called
            if (snapshot.hasChild("isAcceptedBy") && job?.jobOwnerEmailHash != self.emailHash){
                print("Removed Accepted Job From Map")
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
            if (job?.jobOwnerEmailHash != self.emailHash && !(snapshot.hasChild("isAcceptedBy"))){
                
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

        
        let jobDict: [String:Any] = ["latitude":job.latitude, "longitude":job.longitude, "jobOwner":job.jobOwnerEmailHash, "jobTitle":job.title, "jobDescription":job.description, "price":"\(job.wage_per_hour)", "time":"\(job.maxTime)", "fullName":(job.jobOwnerFullName)!, "isAcceptedBy": self.emailHash]

        userAcceptedRef.child(job.jobID).updateChildValues(jobDict)

        jobsRef.child(job.jobID).updateChildValues(jobDict)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userValues = snapshot.value as! [String : AnyObject]
            
            // add the job to job poster's "latestPostAccepted" reference in database
            self.userRef.child(job.jobOwnerEmailHash).child("latestPostAccepted").setValue(self.emailHash)
            //add to the "uAccepted" ref for current user
            self.userRef.child(self.helper.MD5(string: user.email!)).child("didAccept").setValue(job.jobID)
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
        
        userRef.child(emailHash).observeSingleEvent(of: .value) { (status) in
            
            if status.hasChild("latestPostAccepted"){
                
                let dict = status.value as? [String: AnyObject]
                self.jobsRef.child((dict!["lastPost"] as? String)!).observeSingleEvent(of: .value, with: { (jobSnap) in
                
                    if jobSnap.hasChild("isCompleted"){
                        
                        completion(1) // Job was completed but not confirmed payment
                    }
                    
                    else if jobSnap.hasChild("started"){
                        
                        completion(2) // Job was started, both suer and accepter had pressed ready
                    }
                    
                    else if jobSnap.hasChild("accepterReady"){
                        
                        completion(3) // job not confirmed started by the user
                    }
                    
                    else if jobSnap.hasChild("isAcceptedBy"){
                        
                        completion(4) // Job accepter hasnt pressed start yet or isnt arrived yet
                    }
                })
            }
                
                
            else if (status.hasChild("didAccept")){
                
                let dict = status.value as? [String: AnyObject]
                self.jobsRef.child((dict!["didAccept"] as? String)!).observeSingleEvent(of: .value, with: { (jobSnap) in
                    
                    if jobSnap.hasChild("isCompleted"){
                        
                        completion(5) // Job was completed but not confirmed payment
                    }
                        
                    else if jobSnap.hasChild("started"){
                        
                        completion(6) // Job was started, both user and accepter had pressed ready
                    }
                        
                    else if jobSnap.hasChild("accepterReady"){
                        
                        completion(7) // job not confirmed started by the user
                    }
                        
                    else if jobSnap.hasChild("isAcceptedBy"){
                        
                        completion(8) // Job accepter hasnt pressed start yet or isnt arrived yet
                    }
                })
            }
            else{
                completion(0) // if the current user is just a user who didnt accept a job or hasnt has his job accepted
            }
        }
        
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
            else if key == "latestPostAccepted"{
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
        jobsRef.child(job.jobID).updateChildValues(["started":true])
        jobsRef.child(job.jobID).child("isAcceptedBy").observeSingleEvent(of: .value) { (hash) in
            if let accepterHash = hash.value as? String{
                self.userRef.child(accepterHash).child("currentDevice").observeSingleEvent(of: .value, with: { (deviceID) in
                    if let device = deviceID.value as? String{
                        completion(device)
                    }
                })
            }
        }
    }
    
    func getJobPostedByCurrentUser(completion: @escaping(Job) -> ()){
        
        userRef.child(emailHash).observeSingleEvent(of: .value) { (user) in
            
            let lastPostSnapshot = user.childSnapshot(forPath: "lastPost")
            if let lastPost = lastPostSnapshot.value as? String{
                self.jobsRef.child(lastPost).observeSingleEvent(of: .value) { (snapshot) in
                    if let job = Job(snapshot: snapshot){
                        completion(job)
                    }
                    else{
                        print("Could not find job")
                    }
                }
            }
        }
    }
    
    func endJobPressed(job: Job){
        
        userRef.child(emailHash).child("uAccepted").removeValue()
        userRef.child(emailHash).child("didAccept").removeValue()
        jobsRef.child(job.jobID).child("isCompleted").setValue(true)
    }
    
    func confirmedJobEnd(){
        
        userRef.child(emailHash).child("latestPostAccepted").removeValue()
        userRef.child(emailHash).child("lastPost").removeValue()
    }
    
    func checkIfAccepterReady(completion: @escaping(Int) -> ()){
        
        getJobPostedByCurrentUser { (job) in
            
            self.jobsRef.child(job.jobID).observeSingleEvent(of: .value, with: { (snapshot) in
                let job = Job(snapshot: snapshot)
                
                if (snapshot.hasChild("accepterReady")){
                    completion(1) // Code 1 means that the accepter is ready
                }
                else{
                    completion(2) // Accepter isnt ready
                }
            })
        }
    }
    
    func onAccepterPressedReady(completion: @escaping(Int) ->()){
        
        jobsRefHandle = jobsRef.observe(.childChanged, with: { (jobSnap) in
            let jobChanged = Job(snapshot: jobSnap)
            if jobChanged?.jobOwnerEmailHash == self.emailHash{
                jobSnap.ref.observe(.childChanged, with: { (snapshot) in
                    
                    print(snapshot.key, "Here is the snapshot key")
                    if snapshot.key == "accepterReady"{
                        if (snapshot.value as? Bool)!{
                            completion(0) // accepter Ready
                        }
                            
                        else if !(snapshot.value as? Bool)!{
                            completion(1) // accepter not ready
                        }
                    }
                })
            }
        })
    }
    
    func onJobBegun(completion: @escaping(Int) -> ()){
        
        jobsRefHandle = jobsRef.observe(.childChanged, with: { (jobSnap) in
            let jobChanged = Job(snapshot: jobSnap)
            let acceptedBy = jobSnap.value as? [String: AnyObject]
            if (jobChanged?.jobOwnerEmailHash == self.emailHash) || (acceptedBy!["isAcceptedBy"] as? String == self.emailHash){
                jobSnap.ref.observe(.childAdded, with: { (snapshot) in

                    if snapshot.key == "started"{
                        if (snapshot.value as? Bool)!{
                            completion(0) // Job Started
                        }
                            
                        else if !(snapshot.value as? Bool)!{
                            completion(1) // Job not started yet
                        }
                    }
                })
            }
        })
    }
    
    func onJobEnd(completion: @escaping(Int) -> ()){
        
        jobsRef.observe(.childChanged) { (jobPost) in
            
            let job = Job(snapshot: jobPost)
            if job?.jobOwnerEmailHash == self.emailHash{
                
                jobPost.ref.observe(.childChanged, with: { (snap) in
                    
                    if snap.key == "completed"{
                        
                        if (snap.value as? Bool)!{
                            completion(0) // JOB COMPLETED
                        }
                        else{
                            completion(1)
                        }
                    }
                })
            }
        }
    }
    
}









