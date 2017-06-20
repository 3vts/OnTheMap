//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    /// The Facebook login button
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    /// Username Text View
    @IBOutlet weak var userTextView: UITextField!
    /// Password Text View
    @IBOutlet weak var passwordTextView: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.fbLoginButton.loginBehavior = .systemAccount
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
        DispatchQueue.main.async(execute: {self.performSegue(withIdentifier: "LoginSegue", sender: self)})
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
        let _ = UdacityClient.sharedInstance().taskForPOSTMethod(method: UdacityClient.Constants.AuthorizationURL, headers: UdacityClient.Constants.AuthorizationHeaders, jsonBody: jsonBody, pathExtension: UdacityClient.Constants.AuthorizationPath) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                UdacityClient.sharedInstance().showErrorMessage(error!, self)
                return
            }
            self.loadNextView()
        }
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            UdacityClient.sharedInstance().showErrorMessage(error, self)
            return
        }else if result.isCancelled {
            return
        }else {
            guard let token = FBSDKAccessToken.current().tokenString else {
                return
            }
            let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}"
            completeLogin(jsonBody)
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
}
