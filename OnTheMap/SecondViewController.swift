//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

