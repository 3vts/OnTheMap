//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import MapKit

class ListViewController: UITableViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    var students = [Student]()
    var filteredStudents = [Student]()
    var inSearchMode = false
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UdacityClient.sharedInstance().students.isEmpty {
            reloadList()
        } else {
            students = UdacityClient.sharedInstance().students
            tableView.reloadData()
            setActivityindicator(true)
        }
    }
    @IBAction func reloadTapped(_ sender: UIButton) {
        reloadList()
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UdacityClient.sharedInstance().logout(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let source = inSearchMode ? filteredStudents : students
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let source = inSearchMode ? filteredStudents : students
        let student = source[indexPath.row]
        UdacityClient.sharedInstance().locationToCenterMap(coordinate: CLLocationCoordinate2DMake(student.latitude, student.longitude))
        tabBarController!.selectedIndex = 0
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let source = inSearchMode ? filteredStudents : students
        let app = UIApplication.shared
        guard let urlString = Optional(source[indexPath.row].mediaURL), let url = URL(string: urlString) else {
            return
        }
        app.open(url, options: [:], completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let source = inSearchMode ? filteredStudents : students
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationCell")
        let student = source[indexPath.row]
        
        cell?.textLabel?.text = "\(student.firstName) \(student.lastName)"
        if let details =  cell?.detailTextLabel {
            details.text = student.mediaURL
        }
        
        return cell!
    }
    
    func setActivityindicator(_ hide: Bool){
        UIView.animate(withDuration: 0.5) {
            self.loadingIndicator.alpha = hide ? 0.0 : 1.0
            self.searchBar.alpha = hide ? 1.0 : 0.0
            self.loadingIndicator.isHidden = hide
            self.searchBar.isHidden = !hide
        }
    }
    
    func reloadList(){
        setActivityindicator(false)
        UdacityClient.sharedInstance().getStudentsLocations(self){
            self.students = UdacityClient.sharedInstance().students
            performUIUpdatesOnMain {
                self.tableView.reloadData()
                self.setActivityindicator(true)
            }
        }
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text! != "" {
            inSearchMode = true
            let lowerCasedInput = searchBar.text?.lowercased()
            filteredStudents = students.filter({ "\($0.firstName.lowercased()) \($0.lastName.lowercased())".range(of: lowerCasedInput!) != nil })
        }else {
            inSearchMode = false
            self.view.endEditing(true)
        }
        self.tableView.reloadData()
    }
}


