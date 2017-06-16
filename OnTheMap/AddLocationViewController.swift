//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/15/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import CoreLocation


class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var urlTextView: UITextField!
    var geocoder: CLGeocoder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func findLocationTapped(_ sender: UIButton) {
        if geocoder == nil {
            geocoder = CLGeocoder()
        }
        geocoder?.geocodeAddressString(locationTextView.text!, completionHandler: { (placemarks, error) in
            let placemark = placemarks?.first
            let latitute = placemark?.location?.coordinate.latitude
            let longitude = placemark?.location?.coordinate.longitude
            print("\(String(describing: latitute!)), \(String(describing: longitude!))")
            if let presenter = self.presentingViewController as? MapViewController {
                presenter.addPinLocation(CLLocationCoordinate2DMake(latitute!, longitude!), self.urlTextView.text!, self.locationTextView.text!)
            }
        })

        self.dismiss(animated: true, completion: nil)
    }

}
