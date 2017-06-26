//
//  MapViewController+MKMapViewDelegate.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/26/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        setActivityindicator(mapView.annotations.count > 0)
        
        if annotation is MKUserLocation {
            
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        let customPin = annotation as! OnTheMapAnnotation
        pinView!.image = customPin.imageName
        
        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            guard let urlString = view.annotation?.subtitle!, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                return
            }
            app.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        setActivityindicator(false)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        setActivityindicator(true)
    }

}
