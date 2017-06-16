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
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var userTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.fbLoginButton.loginBehavior = .systemAccount
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(userTextView.text!)\", \"password\": \"\(passwordTextView.text!)\"}}"
        let _ = UdacityClient.sharedInstance().taskForPOSTMethod("https://www.udacity.com/api/session", parameters: [:], jsonBody: jsonBody) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                UdacityClient.sharedInstance().showErrorMessage(error!, self)
                return
            }
            print(result)
        }
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    func loadNextView(){
        performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            UdacityClient.sharedInstance().showErrorMessage(error, self)
            return
        }else{
            loadNextView()
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
}
