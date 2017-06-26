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
//        self.fbLoginButton.readPermissions = ["public_profile"]
//        self.fbLoginButton.loginBehavior = .systemAccount
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(userTextView.text!)\", \"password\": \"\(passwordTextView.text!)\"}}"
        completeLogin(jsonBody)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    ///This method is used to load the next view. It uses Dyspatch async to avoid errors
    func loadNextView(){
        self.performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /**
     Login handler. Used to parse the result of taskForPOSTMethod
     - Parameter jsonBody:   The body for the request.
     */
    func completeLogin(_ jsonBody: String){
        self.view.endEditing(true)
        let _ = UdacityClient.sharedInstance().taskForPOSTMethod(host: UdacityClient.Constants.AuthorizationHost, headers: UdacityClient.Constants.AuthorizationHeaders, jsonBody: jsonBody, pathExtension: UdacityClient.Constants.AuthorizationPath) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                UdacityClient.sharedInstance().showErrorMessage(error!, self)
                return
            }
            guard let result = result as? [String:[String:AnyObject]] else {
                return
            }
            guard let sessionInfo = result["session"], let expirationDate = sessionInfo["expiration"] as? String else {
                return
            }
            guard let accountInfo = result["account"], let user = accountInfo["key"] as? String else {
                return
            }
            let dateString = String("\(expirationDate)".characters.dropLast(8)) + "z"
            let isoFormatter = ISO8601DateFormatter()
            guard let sessionExpirationDate = isoFormatter.date(from: dateString) else {
                return
            }
            self.getUserData(user)
            UserDefaults.standard.set(sessionExpirationDate, forKey: "SESSION_EXPIRATION_DATE")
            UserDefaults.standard.synchronize()
            performUIUpdatesOnMain {
                self.loadNextView()
            }
        }
    }
    
    func getUserData(_ user: String){
        let _ = UdacityClient.sharedInstance().taskForGETMethod(host: UdacityClient.Constants.AuthorizationHost, pathExtension: UdacityClient.Constants.UserPath + user, drop: true) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                UdacityClient.sharedInstance().showErrorMessage(error!, self)
                return
            }
            guard let result = result as? [String:AnyObject] else {
                return
            }
            guard let userData = result["user"], let firstName = userData["first_name"] as? String, let lastName = userData["last_name"] as? String else {
                return
            }
            UserDefaults.standard.set(firstName, forKey: "USER_FIRST_NAME")
            UserDefaults.standard.set(lastName, forKey: "USER_LAST_NAME")
            UserDefaults.standard.set(user, forKey: "KEY")
        }
    }
    
    

    
}
