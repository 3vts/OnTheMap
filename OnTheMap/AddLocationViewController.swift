//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/15/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddLocationViewController: UIViewController {
    
    /// Location Text View. Used to fetch the coordinates
    @IBOutlet weak var locationTextView: UITextField!
    /// URL Text View. Used to enter user custom URL
    @IBOutlet weak var urlTextView: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var setLocationButton: UIButton!
    var geocoder: CLGeocoder?
    
    struct locationToPin {
        let location: CLLocationCoordinate2D
        let url: String
        let title: String
        let region: MKCoordinateRegion
        
        
        init(location: CLLocationCoordinate2D, url: String, title: String, region: MKCoordinateRegion) {
            self.location = location
            self.url = url
            self.title = title
            self.region = region
        }
    }
    
    var myAnnotation: locationToPin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func locationTextChanged(_ sender: UITextField) {
        findLocationButton.isEnabled = (sender.text! != "")
        findLocationButton.alpha = (sender.text! != "") ? 1 : 0.7
        
    }
    
    @IBAction func websiteTextChanged(_ sender: UITextField) {
        setLocationButton.isEnabled = (sender.text! != "")
        setLocationButton.alpha = (sender.text! != "") ? 1 : 0.7
    }
    
    @IBAction func setLocationTapped(_ sender: UIButton) {
        guard let urlString = urlTextView.text, URL(string: urlString) != nil else {
            let controller = UIAlertController(title: "Invalid URL", message: "The URL should be valid", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(controller, animated: true, completion: nil)
            return
        }
        let latitude = mapView.annotations.first?.coordinate.latitude
        let longitude = mapView.annotations.first?.coordinate.longitude
        let location = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        myAnnotation = locationToPin(location: location, url: urlString, title: "Test", region: region)
        performSegue(withIdentifier: "showMap", sender: location)
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        if geocoder == nil {
            geocoder = CLGeocoder()
        }
        geocoder?.geocodeAddressString(locationTextView.text!, completionHandler: { (placemarks, error) in
            guard let placemark = placemarks?.first  else {
                UdacityClient.sharedInstance().showErrorMessage(error!, self)
                return
            }
            let latitute = placemark.location?.coordinate.latitude
            let longitude = placemark.location?.coordinate.longitude
            performUIUpdatesOnMain {
                self.addPinLocation(CLLocationCoordinate2DMake(latitute!, longitude!))
            }
        })
        self.mapView.isHidden = false
        self.setLocationButton.isHidden = false
        self.view.endEditing(true)
    }

}

extension AddLocationViewController: MKMapViewDelegate {
    func addPinLocation(_ location: CLLocationCoordinate2D)  {
        let annotation = OnTheMapAnnotation()
        self.mapView.removeAnnotations(self.mapView.annotations)
        annotation.imageName = UIImage(named: "icon_pin")
        annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        
        let customPin = annotation as! OnTheMapAnnotation
        pinView?.image = customPin.imageName
        
        return pinView
    }
}


