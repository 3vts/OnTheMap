//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/14/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    /// A Location Manager used to fetch user's location
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UdacityClient.sharedInstance().students.isEmpty || mapView.annotations.count == 0 {
            reloadAnnotations()
        }
        let region = UdacityClient.sharedInstance().region
        if region != nil {
            zoomMapToPin(region!)
        }
    }
    
    @IBAction func showMyPinLocation(segue:UIStoryboardSegue){
        if let sourceViewController = segue.source as? AddLocationViewController {
            if let myAnnotation = sourceViewController.myAnnotation {
                addPinLocation(myAnnotation.location, myAnnotation.url, myAnnotation.title)
                zoomMapToPin(myAnnotation.region)
            }
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UdacityClient.sharedInstance().logout(self)
    }
    
    @IBAction func reloadTapped(_ sender: UIButton) {
        locationManager.requestLocation()
        reloadAnnotations()
    }
    
    @IBAction func selectMapChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .hybrid
        }
    }
    
    @IBAction func addLocationTapped(_ sender: UIButton) {
        UdacityClient.sharedInstance().previouslyPosted(self)
    }
    
    func addPinLocation(_ location: CLLocationCoordinate2D, _ url: String, _ title: String)  {
        let annotation = OnTheMapAnnotation()
        annotation.imageName = UIImage(named: "icon_pin")
        annotation.coordinate = location
        annotation.title = title
        annotation.subtitle = url
        self.mapView.addAnnotation(annotation)
    }
    
    func zoomMapToPin(_ region: MKCoordinateRegion){
        mapView.setRegion(region, animated: true)
        UdacityClient.sharedInstance().region = nil
    }
    
    func setActivityindicator(_ hide: Bool){
        self.view.isUserInteractionEnabled = hide
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = hide ? 1.0 : 0.7
            self.loadingIndicator.alpha = hide ? 0.0 : 1.0
            self.loadingIndicator.isHidden = hide
        }
    }
    
    
    func showAnnotations() {
        for student in UdacityClient.sharedInstance().students {
            let location = CLLocationCoordinate2DMake(student.latitude, student.longitude)
            let url = student.mediaURL
            let title = "\(student.firstName) \(student.lastName)"
            performUIUpdatesOnMain {
                self.addPinLocation(location, url, title)
            }
        }
        
    }
    
    func reloadAnnotations(){
        setActivityindicator(false)
        mapView.removeAnnotations(mapView.annotations)
        UdacityClient.sharedInstance().getStudentsLocations(self){
            self.showAnnotations()
        }
    }
}


