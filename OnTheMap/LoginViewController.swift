//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    /// The Facebook login button
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    /// Username Text View
    @IBOutlet weak var userTextView: UITextField!
    /// Password Text View
    @IBOutlet weak var passwordTextView: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for const in fbLoginButton.constraints{
            if const.firstAttribute == NSLayoutAttribute.height && const.constant == 28{
                fbLoginButton.removeConstraint(const)
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(userTextView.text!)\", \"password\": \"\(passwordTextView.text!)\"}}"
        UdacityClient.sharedInstance().completeLogin(jsonBody, self) { 
            performUIUpdatesOnMain {
                self.loadNextView()
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    ///This method is used to load the next view.
    func loadNextView(){
        performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    

    
    

    
}
