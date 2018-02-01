//
//  EmailVerifyVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 8/6/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Lottie
import Pastel
import Firebase
import Material
import PopupDialog

class EmailVerifyVC: UIViewController {

    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    @IBOutlet weak var continueButtonEmail: UIButton!
    @IBOutlet weak var emailCheckAnimation: UIView!
    var firstName : String!
    var lastName: String!
    var dbRef : DatabaseReference!
    var newUserUID: String!
    var checkEmail = LOTAnimationView()
    var loadingAnimation = LOTAnimationView()
    var user: User?
    var emailPopup: PopupDialog?
    
    override func viewDidLoad() {
        checkEmail = self.view.returnHandledAnimation(filename: "check", subView: emailCheckAnimation, tagNum: 1)
        
        super.viewDidLoad()
        super.viewDidAppear(true)
        dbRef = Database.database().reference()
        self.prepareTitleTextField()
        self.navigationController?.navigationBar.isHidden = false
        gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.3476088047, green: 0.1101973727, blue: 0.08525472134, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.continueButtonEmail.makeButtonAppear()
        self.gradientView.startAnimation()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueOnTextField(_ sender: Any) {
        
        self.dismissKeyboard()
        if (emailTF?.text?.isEmpty != true && passwordTF?.text?.isEmpty != true){
            Auth.auth().currentUser?.delete(completion: { (err) in
                if let error = err{
                    
                    print(error.localizedDescription)
                }
                self.loadingAnimation = self.view.returnHandledAnimation(filename: "loading", subView: self.emailCheckAnimation, tagNum: 2)
                self.continueButtonEmail.makeButtonDissapear()
                self.loadingAnimation.play()
                self.loadingAnimation.loopAnimation = true
                Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!, completion: { (user, error) in
                    if (error != nil){
                        print("error when creating user")
                        self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                        let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                        errorEmail.play()
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                            self.continueButtonEmail.makeButtonAppear()
                        }
                        print(error as Any)
                        return
                    }
                    else{
                        print("error with popup")
                        self.user = user
                        user?.sendEmailVerification(completion: { (err) in
                            if let error = err {
                                print(error.localizedDescription)
                            }
                        })
                        self.emailPopup = self.prepareEmailVerifyPopup(user: user!)
                        
                        self.present(self.emailPopup!, animated: true, completion: {
                            self.loadingAnimation.stop()
                            self.loadingAnimation.makeAnimationDissapear(tag: 2)
                            self.continueButtonEmail.makeButtonAppear()
                        })
                        
                    }
                })
            })
            
            self.loadingAnimation = self.view.returnHandledAnimation(filename: "loading", subView: self.emailCheckAnimation, tagNum: 2)
            self.continueButtonEmail.makeButtonDissapear()
            self.loadingAnimation.play()
            self.loadingAnimation.loopAnimation = true
            Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!, completion: { (user, error) in
                if (error != nil){
                    print("error when creating user")
                    self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                    let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                    errorEmail.play()
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                        self.continueButtonEmail.makeButtonAppear()
                    }
                    print(error as Any)
                    return
                }
                else{
                    print("error with popup")
                    self.user = user
                    user?.sendEmailVerification(completion: { (err) in
                        if let error = err {
                            print(error.localizedDescription)
                        }
                    })
                    self.emailPopup = self.prepareEmailVerifyPopup(user: user!)
                    
                    self.present(self.emailPopup!, animated: true, completion: {
                        self.loadingAnimation.stop()
                        self.loadingAnimation.makeAnimationDissapear(tag: 2)
                        self.continueButtonEmail.makeButtonAppear()
                    })
                    
                }
            })
        }
        
    }
    
    @IBAction func continueButtonEmail(_ sender: UIButton) {
        
        
        if (emailTF?.text?.isEmpty != true && passwordTF?.text?.isEmpty != true){
            Auth.auth().currentUser?.delete(completion: { (err) in
                if let error = err{

                    print(error.localizedDescription)
                }
                self.loadingAnimation = self.view.returnHandledAnimation(filename: "loading", subView: self.emailCheckAnimation, tagNum: 2)
                self.continueButtonEmail.makeButtonDissapear()
                self.loadingAnimation.play()
                self.loadingAnimation.loopAnimation = true
                Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!, completion: { (user, error) in
                    if (error != nil){
                        print("error when creating user")
                        self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                        let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                        errorEmail.play()
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                            self.continueButtonEmail.makeButtonAppear()
                        }
                        print(error as Any)
                        return
                    }
                    else{
                        print("error with popup")
                        self.user = user
                        user?.sendEmailVerification(completion: { (err) in
                            if let error = err {
                                print(error.localizedDescription)
                            }
                        })
                        self.emailPopup = self.prepareEmailVerifyPopup(user: user!)
                        
                        self.present(self.emailPopup!, animated: true, completion: {
                            self.loadingAnimation.stop()
                            self.loadingAnimation.makeAnimationDissapear(tag: 2)
                            self.continueButtonEmail.makeButtonAppear()
                        })
                        
                    }
                })
            })
            
            self.loadingAnimation = self.view.returnHandledAnimation(filename: "loading", subView: self.emailCheckAnimation, tagNum: 2)
            self.continueButtonEmail.makeButtonDissapear()
            self.loadingAnimation.play()
            self.loadingAnimation.loopAnimation = true
            Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!, completion: { (user, error) in
                if (error != nil){
                    print("error when creating user")
                    self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                    let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                    errorEmail.play()
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                        self.continueButtonEmail.makeButtonAppear()
                    }
                    print(error as Any)
                    return
                }
                else{
                    print("error with popup")
                    self.user = user
                    user?.sendEmailVerification(completion: { (err) in
                        if let error = err {
                            print(error.localizedDescription)
                        }
                    })
                    self.emailPopup = self.prepareEmailVerifyPopup(user: user!)
                    
                    self.present(self.emailPopup!, animated: true, completion: {
                        self.loadingAnimation.stop()
                        self.loadingAnimation.makeAnimationDissapear(tag: 2)
                        self.continueButtonEmail.makeButtonAppear()
                    })
                    
                }
            })
        }
    }

    
    func prepareTitleTextField(){
        
        self.emailTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.emailTF.font = UIFont(name: "Century Gothic", size: 17)
        self.emailTF.textColor = Color.white
        self.emailTF.placeholder = "Email"
        self.emailTF.placeholderActiveColor = Color.white
        self.emailTF.placeholderNormalColor = Color.white
        self.passwordTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.passwordTF.font = UIFont(name: "Century Gothic", size: 17)
        self.passwordTF.textColor = Color.white
        self.passwordTF.placeholder = "Password"
        self.passwordTF.placeholderActiveColor = Color.white
        self.passwordTF.placeholderNormalColor = Color.white
        
        
    }
    
    func prepareEmailVerifyPopup(user: User) -> PopupDialog{
        
        let title = "Verify your email"
        let message = "Please check your email for a verification link, then press continue after verifying"
        let emailVerifyPopup = PopupDialog(title: title, message: message)
        let continueButton = DefaultButton(title: "Continue", dismissOnTap: false){
            
            user.reload(completion: { (err) in
                if let error = err{
                    print(error.localizedDescription)
                    return
                }
                if user.isEmailVerified{
                    emailVerifyPopup.dismiss()
                    self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                    self.addNewUserToDBJson()
                    let profile = user.createProfileChangeRequest()
                    profile.displayName = "\(self.firstName!) \(self.lastName!)"
                    profile.commitChanges(completion: { (error2) in
                        if (error2 != nil){
                            let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                            errorEmail.play()
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when){
                                self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                                self.continueButtonEmail.makeButtonAppear()
                            }
                            print(error2 as Any)
                            return
                        }
                        else{
                            self.emailCheckAnimation.handledAnimation(Animation: self.checkEmail)
                            self.continueButtonEmail.makeButtonDissapear()
                            self.checkEmail.play()
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when){
                                self.checkEmail.stop()
                                self.performSegue(withIdentifier: "chooseProfilePicture", sender: self)
                                
                            }
                        }
                    })
                }
                else{
                    emailVerifyPopup.shake()
                }
            })
        }
        emailVerifyPopup.addButton(continueButton)
        
        return emailVerifyPopup
    }
    
    
    func MD5(string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    

    func addNewUserToDBJson(){

        let rating: Float = 5.0

        self.newUserUID = Auth.auth().currentUser?.uid
        let emailHash = MD5(string: self.emailTF.text!)

        self.dbRef.child("Users").child(emailHash).child("uid").setValue(self.newUserUID)
        self.dbRef.child("Users").child(emailHash).child("Name").setValue("\(firstName!) \(lastName!)")
        self.dbRef.child("Users").child(emailHash).child("Email").setValue(emailTF.text)
        self.dbRef.child("Users").child(emailHash).child("Rating").setValue(rating)
        self.dbRef.child("Users").child(emailHash).child("Ratings Sum").setValue(0)
        self.dbRef.child("Users").child(emailHash).child("currentDevice").setValue(AppDelegate.DEVICEID)
    }



}
