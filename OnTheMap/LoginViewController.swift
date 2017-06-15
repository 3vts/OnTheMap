//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  
    @IBAction func buttonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginSegue", sender: self)
    }
    @IBAction func signUpTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string:"https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }

}
