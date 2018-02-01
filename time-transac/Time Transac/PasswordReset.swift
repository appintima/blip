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

class PasswordReset: UIViewController {

    @IBOutlet var gradientView: PastelView!
    @IBOutlet weak var emailTF: TextField!
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
    }
    
    @IBAction func sendLink(_ sender: UIButton) {
        if !(self.emailTF.text?.isEmpty)!{
            if let email = self.emailTF.text{
                Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                    if let error = error{
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
    

}
