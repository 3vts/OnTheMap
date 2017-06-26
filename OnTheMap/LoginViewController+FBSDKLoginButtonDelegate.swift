//
//  LoginViewController+FBSDKLoginButtonDelegate.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/26/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import FBSDKLoginKit

extension LoginViewController:  FBSDKLoginButtonDelegate{
    
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
