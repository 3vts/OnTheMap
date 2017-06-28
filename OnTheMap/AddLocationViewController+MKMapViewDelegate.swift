//
//  AddLocationViewController+MKMapViewDelegate.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/26/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import MapKit

extension AddLocationViewController: MKMapViewDelegate {
    func addPinLocation(_ location: CLLocationCoordinate2D)  {
        let annotation = OnTheMapAnnotation()
        mapView.removeAnnotations(mapView.annotations)
        annotation.imageName = UIImage(named: "icon_pin")
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
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
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        setActivityindicator(true)
    }
}
