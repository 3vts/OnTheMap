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
    
    /**
     Function to create a URL from parameters
     
     - parameter host: URL Host for the request
     - parameter parameters: Parameters for the request
     - parameter withPathExtension: Path for the URL request
     - returns: The URL created from the received parameters
     
     */
    
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
    
    /**
     Function to create an error from a given String
     
     - parameter error: String containing the localizedDescription for the error
     - parameter domain: Domain in which the function was called
     - returns: The Error created from the received parameters
     
     */
    func createError(_ error: String, _ domain: String) -> Error {
        let userInfo = [NSLocalizedDescriptionKey : error]
        return NSError(domain: domain, code: 1, userInfo: userInfo)
    }
    
    /**
     Function to check if the used has posted his location previously
     
     - parameter sender: ViewController from which the method was called. Used in the cases a message has to be displayed
     
     */
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
    
    /**
     Function to request the check if the used has posted his location previously
     
     - parameter uniqueKey: The uniqueKey for the Student post
     - parameter completion: A closure indicating if the user posted previously or not
     
     */
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
     Function used to get and parse the Students Locations
     
     - parameter sender: ViewController from which the method was called Used in the cases a message has to be displayed
     - parameter update: A closure that indicates the end of the function
     
     */
    func getStudentsLocations(_ sender: UIViewController, update:@escaping ()->Void = {}) {
        let methodParameters = [
            ParameterKeys.Limit : ParameterValues.Limit,
            ParameterKeys.Skip : ParameterValues.Skip,
            ParameterKeys.Order : ParameterValues.Order
            ] as [String:AnyObject]
        
        let _ = taskForGETMethod(host: Constants.ApiHost, headers: Constants.ApiHeaders, parameters:  methodParameters, pathExtension:  Constants.ApiPath) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                self.showErrorMessage(error!, sender)
                return
            }
            self.students = Student.studentsFromResults(result?["results"] as! [[String:AnyObject]])
            update()
        }
        
    }
    
    /**
     Function used to create the region for the pinned location
     
     - parameter coordinate: Geographic coordinates of the location
     
     */
    func locationToCenterMap(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(1.5, 1.5)
        region = MKCoordinateRegionMake(coordinate, span)
    }
    
    /**
     Function used to show a message given an error
     
     - parameter error: Error to be displayed
     - parameter sender: ViewController to display the error
     
     */
    func showErrorMessage(_ error: Error, _ sender: UIViewController){
        performUIUpdatesOnMain {
            let controller = UIAlertController(title: "Oops...", message: error.localizedDescription, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            sender.present(controller, animated: true, completion: nil)
        }
    }
    
    /**
     Function used to logout the user and delete the session information
     
     - parameter sender: ViewController from which the method was called Used in the cases a message has to be displayed
     
     */
    
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
    
    /**
     Function used to finish the logout and perform the screen transition
     
     - parameter sender: ViewController from which the method was called Used for the screen transition
     
     */
    func finishLogout(_ sender: UIViewController){
        performUIUpdatesOnMain {
            let loginViewController = sender.storyboard?.instantiateViewController(withIdentifier: "login")
            UIApplication.shared.keyWindow?.rootViewController = loginViewController
            sender.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
