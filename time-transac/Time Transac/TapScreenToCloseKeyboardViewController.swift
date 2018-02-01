//
//  TapScreenToCloseKeyboardViewController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 7/31/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }


}
