//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import MapKit

class ListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredStudents = [Student]()
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(ListViewController.handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    func handleRefresh() {
        reloadList { 
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UdacityClient.sharedInstance().students.isEmpty {
            reloadList({})
        }
    }
    
    @IBAction func addLocationTapped(_ sender: UIButton) {
        UdacityClient.sharedInstance().previouslyPosted(self)
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UdacityClient.sharedInstance().logout(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let source = inSearchMode ? filteredStudents : UdacityClient.sharedInstance().students
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let source = inSearchMode ? filteredStudents : UdacityClient.sharedInstance().students
        let student = source[indexPath.row]
        UdacityClient.sharedInstance().locationToCenterMap(coordinate: CLLocationCoordinate2DMake(student.latitude, student.longitude))
        tabBarController!.selectedIndex = 0
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let source = inSearchMode ? filteredStudents : UdacityClient.sharedInstance().students
        let app = UIApplication.shared
        guard let urlString = Optional(source[indexPath.row].mediaURL), let url = URL(string: urlString) else {
            return
        }
        app.open(url, options: [:], completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let source = inSearchMode ? filteredStudents : UdacityClient.sharedInstance().students
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationCell")
        let student = source[indexPath.row]
        
        cell?.textLabel?.text = "\(student.firstName) \(student.lastName)"
        if let details =  cell?.detailTextLabel {
            details.text = student.mediaURL
        }
        
        return cell!
    }
    
    func reloadList(_ completion: @escaping ()->()){
        UdacityClient.sharedInstance().getStudentsLocations(self){
            performUIUpdatesOnMain {
                self.tableView.reloadData()
                completion()
            }
        }
    }
}




