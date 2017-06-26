//
//  UdacityClientConvenience.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/26/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

extension UdacityClient {
    
    // create a URL from parameters
    func udacityURLFromParameters(_ host: String, _ parameters: [String:AnyObject]? = nil, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = host
        components.path = withPathExtension ?? ""
        
        if parameters != nil {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters! {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    func createError(_ error: String, _ domain: String) -> Error {
        let userInfo = [NSLocalizedDescriptionKey : error]
        return NSError(domain: domain, code: 1, userInfo: userInfo)
    }
    
    func previouslyPosted(_ sender: UIViewController){
        guard let userKey = UserDefaults.standard.value(forKey: "KEY") as? String else {
            return
        }
        let _ =  finishPreviouslyPosted(userKey) { (posted) in
            if posted == true {
                performUIUpdatesOnMain {
                    let alertView = UIAlertController(title: "Previously posted Content", message: "You have already posted a student location. Would you like to overwrite your current location?", preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: { (result) in
                        performUIUpdatesOnMain {
                            sender.performSegue(withIdentifier: "showAddLocation", sender: "PUT")
                        }
                    }))
                    alertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    sender.present(alertView, animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    sender.performSegue(withIdentifier: "showAddLocation", sender: "POST")
                }
            }
        }
    }
    
    func finishPreviouslyPosted(_ uniqueKey: String, completion: @escaping (Bool) -> ()) {
        
        let methodParameters = [
            ParameterKeys.Where : "{\"uniqueKey\":\"\(uniqueKey)\"}"
            ] as [String:AnyObject]
        
        let _ = taskForGETMethod(host: Constants.ApiHost, headers: Constants.ApiHeaders, parameters: methodParameters, pathExtension: Constants.ApiPath) { (result, error) in
            guard let resultsDict = result as? [String:AnyObject], let results = resultsDict["results"] as? [[String:AnyObject]] else {
                return
            }
            if results.count == 0{
                completion(false)
            } else {
                self.objectID = results[0]["objectId"] as? String
                completion(true)
            }
        }
    }
    
    /**
     Method used to get and parse the Students Locations
     
     - returns: An array containing all the Students Locations
     
     */
    
    func getStudentsLocations(_ view: UIViewController, update:@escaping ()->Void = {}) //-> [Student] {
    {
        let methodParameters = [
            ParameterKeys.Limit : ParameterValues.Limit,
            ParameterKeys.Skip : ParameterValues.Skip,
            ParameterKeys.Order : ParameterValues.Order
            ] as [String:AnyObject]
        
        let _ = taskForGETMethod(host: Constants.ApiHost, headers: Constants.ApiHeaders, parameters:  methodParameters, pathExtension:  Constants.ApiPath) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                self.showErrorMessage(error!, view)
                return
            }
            self.students = Student.studentsFromResults(result?["results"] as! [[String:AnyObject]])
            update()
        }
        
    }
    
    func locationToCenterMap(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(1.5, 1.5)
        region = MKCoordinateRegionMake(coordinate, span)
    }
    
    func showErrorMessage(_ error: Error, _ sender: UIViewController){
        performUIUpdatesOnMain {
            let controller = UIAlertController(title: "Oops...", message: error.localizedDescription, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            sender.present(controller, animated: true, completion: nil)
        }
    }
    
    func logout(_ sender: UIViewController) {
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
            finishLogout(sender)
        } else {
            _ = taskForDeleteMethod(host: Constants.AuthorizationHost, pathExtension: Constants.AuthorizationPath, completionHandlerForDelete: { (result, error) in
                guard (error == nil) else {
                    self.showErrorMessage(error!, sender)
                    return
                }
                if (UserDefaults.standard.value(forKey:"SESSION_EXPIRATION_DATE") as? Date) != nil {
                    UserDefaults.standard.set(Date(timeIntervalSince1970: 0), forKey: "SESSION_EXPIRATION_DATE")
                    UserDefaults.standard.removeObject(forKey: "USER_FIRST_NAME")
                    UserDefaults.standard.removeObject(forKey: "USER_LAST_NAME")
                    UserDefaults.standard.removeObject(forKey: "KEY")
                    UserDefaults.standard.synchronize()
                }
                self.finishLogout(sender)
            })
        }
    }
    
    func finishLogout(_ sender: UIViewController){
        performUIUpdatesOnMain {
            let loginViewController = sender.storyboard?.instantiateViewController(withIdentifier: "login")
            UIApplication.shared.keyWindow?.rootViewController = loginViewController
            sender.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
