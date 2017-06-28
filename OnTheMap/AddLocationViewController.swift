//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/15/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    /// Location Text View. Used to fetch the coordinates
    @IBOutlet weak var locationTextView: UITextField!
    /// URL Text View. Used to enter user custom URL
    @IBOutlet weak var urlTextView: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIView!
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
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func locationTextChanged(_ sender: UITextField) {
        findLocationButton.isEnabled = (sender.text! != "")
        findLocationButton.alpha = (sender.text! != "") ? 1 : 0.5
        
    }
    
    @IBAction func websiteTextChanged(_ sender: UITextField) {
        setLocationButton.isEnabled = (sender.text! != "")
        setLocationButton.alpha = (sender.text! != "") ? 1 : 0.5
    }
    
    @IBAction func setLocationTapped(_ sender: UIButton) {
        guard let urlString = urlTextView.text, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            let controller = UIAlertController(title: "Invalid URL", message: "The URL should be valid", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
            return
        }
        let latitude = mapView.annotations.first?.coordinate.latitude
        let longitude = mapView.annotations.first?.coordinate.longitude
        let location = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        guard let firstName = UserDefaults.standard.value(forKey:"USER_FIRST_NAME"),let lastName = UserDefaults.standard.value(forKey:"USER_LAST_NAME") else {
            return
        }
        guard let uniqueKey = UserDefaults.standard.value(forKey: "KEY") as? String else{
            return
        }
        let fullName = "\(firstName) \(lastName)"
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(locationTextView.text!)\", \"mediaURL\": \"\(urlTextView.text!)\", \"latitude\": \(latitude!), \"longitude\": \(longitude!)}"
        UdacityClient.sharedInstance().postStudentLocation(jsonBody, self) { (success) in
            if success == true {
                self.myAnnotation = locationToPin(location: location, url: urlString, title: fullName, region: region)
                UdacityClient.sharedInstance().getStudentsLocations(self, update: {
                    performUIUpdatesOnMain {
                        self.performSegue(withIdentifier: "showMap", sender: location)
                    }
                })
            }
        }
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        setActivityindicator(false)
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
        mapView.isHidden = false
        setLocationButton.isHidden = false
        view.endEditing(true)
    }
    
    func setActivityindicator(_ hide: Bool){
        view.isUserInteractionEnabled = hide
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = hide ? 1.0 : 0.7
            self.loadingIndicator.alpha = hide ? 0.0 : 1.0
            self.loadingIndicator.isHidden = hide
        }
    }
    
}


