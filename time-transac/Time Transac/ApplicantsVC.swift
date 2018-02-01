////
////  ApplicantsVC.swift
////  Time Transac
////
////  Created by Gbenga Ayobami on 2018-01-02.
////  Copyright © 2018 Gbenga Ayobami. All rights reserved.
////
//
//import UIKit
//import Lottie
//
//class ApplicantsVC: UITableViewController {
//    
//    var applicantsDict: [String:String]!
//    var applicantsEHashArr:[String]!
//    let ratingAnimation = LOTAnimationView(name: "5_stars")
//    var clickedApplicantInfo: [String:AnyObject]!
//    let service = ServiceCalls()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        applicantsEHashArr = Array(applicantsDict.keys)
//       
//        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
//        self.tableView.register(nib, forCellReuseIdentifier: "tableViewCell")
//        
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return applicantsEHashArr.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! CustomTableViewCell
//        let eHash = applicantsEHashArr[indexPath.row]
////        service.getApplicantProfile(emailHash: eHash) { (applicantInfo) in
////            cell.fullNameLabel.text = (applicantInfo["Name"] as! String)
////            let picURL = URL(string: (applicantInfo["photoURL"] as! String))
////            cell.profilePic.kf.setImage(with: picURL)
////            cell.ratingsView.handledAnimation(Animation: self.ratingAnimation)
////            self.ratingAnimation.play(toProgress: CGFloat((applicantInfo["Rating"] as! Float)/5), withCompletion: nil)
////        }
//        
////        cell.fullNameLabel.text = self.applicantsDict[self.applicantsEHashArr[indexPath.row]]
//        
//        return cell
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 156
//    }
//   
////    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let eHash = applicantsEHashArr[indexPath.row]
////        service.getApplicantProfile(emailHash: eHash) { (applicantInfo) in
////            self.clickedApplicantInfo = applicantInfo
////            self.performSegue(withIdentifier: "goToProfile", sender: nil)
////        }
////    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToProfile"{
//            if let dest = segue.destination as? ConfirmProfilePageVC{
//                dest.applicantInfo = self.clickedApplicantInfo
//            }
//        }
//    }
//
//}

