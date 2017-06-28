//
//  ListViewController+UISearchBarDelegate.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/26/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import UIKit

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text! != "" {
            inSearchMode = true
            let lowerCasedInput = searchBar.text?.lowercased()
            filteredStudents = UdacityClient.sharedInstance().students.filter({ "\($0.firstName.lowercased()) \($0.lastName.lowercased())".range(of: lowerCasedInput!) != nil })
        }else {
            inSearchMode = false
            view.endEditing(true)
        }
        tableView.reloadData()
    }
}
