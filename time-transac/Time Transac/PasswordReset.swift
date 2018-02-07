//
//  PasswordReset.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-30.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Firebase
import Material
import Pastel
import PopupDialog

class PasswordReset: UIViewController {

    @IBOutlet var gradientView: PastelView!
    @IBOutlet weak var emailTF: TextField!
    var connectivity = Connectivity()
    var internet:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField()
        gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.3476088047, green: 0.1101973727, blue: 0.08525472134, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        gradientView.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        gradientView.startAnimation()
        connectivity?.whenReachable = {_ in
            
        }
        connectivity?.whenUnreachable = {_ in
            DispatchQueue.main.async {
                print("NO INTERNET WHEN I STARTED")
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged), name: Notification.Name.reachabilityChanged, object: connectivity)
        do{
            try connectivity?.startNotifier()
        }catch{
            print("Could not start the notifier")
        }
    }
    
    @objc func connectivityChanged(notification: Notification){
        let connectivity = notification.object as! Connectivity
        if (connectivity.connection == .wifi || connectivity.connection == .cellular){
            self.internet = true
            print("REGAINED CONNECTION")
        }else{
            self.internet = false
            print("Connection Gone")
        }
    }
    
    @IBAction func sendLink(_ sender: UIButton) {
        if !(internet){
            let popup = popupForNoInternet()
            self.present(popup, animated: true, completion: nil)
            return
        }
        if !(self.emailTF.text?.isEmpty)!{
            if let email = self.emailTF.text{
                Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                    if let error = error{
                        self.present(self.ERR_WRONG_EMAIL(), animated: true, completion: nil)
                        print(error.localizedDescription)
                        return
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }else{
            print("PLEASE ENTER YOUR EMAIL")
        }
    }
    
    func prepareTextField(){
        self.emailTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.emailTF.font = UIFont(name: "Century Gothic", size: 17)
        self.emailTF.textColor = Color.white
        self.emailTF.placeholder = "Email"
        self.emailTF.placeholderActiveColor = Color.white
        self.emailTF.placeholderNormalColor = Color.white
    }
    
    private func popupForNoInternet()-> PopupDialog {
        let title = "Internet Unavailable"
        let message = "Please connect to the internet and try again"
        let okButton = CancelButton(title: "OK") {
            return
        }
        let popup = PopupDialog(title: title, message: message)
        popup.addButton(okButton)
        return popup
    }
    
    private func ERR_WRONG_EMAIL()-> PopupDialog {
        let title = "Faulty Email"
        let message = "Please check your email and try again"
        let okButton = CancelButton(title: "OK") {
            return
        }
        let popup = PopupDialog(title: title, message: message)
        popup.addButton(okButton)
        return popup
    }

}
