//
//  MapViewController+CLLocationManagerDelegate.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/26/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(50.0, 50.0)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = UdacityClient.sharedInstance().createError("Unable to acquire your location", "locationManager")
        UdacityClient.sharedInstance().showErrorMessage(error, self)
    }
    
    
}
