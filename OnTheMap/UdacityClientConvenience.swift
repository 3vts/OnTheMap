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
            StudentDataSource.sharedInstance.students = Student.studentsFromResults(result?["results"] as! [[String:AnyObject]])
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
    
    /**
      Function used to parse the result of taskForPOSTMethod
     
     - Parameter jsonBody:   The body for the request.
     - parameter sender: ViewController from which the method was called Used in the cases a message has to be displayed
     - parameter completion: A closure which is called to finish the method call
     
     */
    func completeLogin(_ jsonBody: String, _ sender: UIViewController, completion: @escaping () -> ()){
        sender.view.endEditing(true)
        let _ = taskForPOSTMethod(host: Constants.AuthorizationHost, headers: Constants.AuthorizationHeaders, jsonBody: jsonBody, pathExtension: Constants.AuthorizationPath) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                self.showErrorMessage(error!, sender)
                return
            }
            guard let result = result as? [String:[String:AnyObject]] else {
                return
            }
            guard let sessionInfo = result["session"], let expirationDate = sessionInfo["expiration"] as? String else {
                return
            }
            guard let accountInfo = result["account"], let user = accountInfo["key"] as? String else {
                return
            }
            let dateString = String("\(expirationDate)".characters.dropLast(8)) + "z"
            let isoFormatter = ISO8601DateFormatter()
            guard let sessionExpirationDate = isoFormatter.date(from: dateString) else {
                return
            }
            self.getUserData(user, sender)
            UserDefaults.standard.set(sessionExpirationDate, forKey: "SESSION_EXPIRATION_DATE")
            UserDefaults.standard.synchronize()
            completion()
        }
    }
    
    /**
     Function used to get the user data and store it on UserDefaults
     
     - parameter user: String containing the userID
     - parameter sender: ViewController from which the method was called Used in the cases a message has to be displayed
     
     */
    func getUserData(_ user: String, _ sender: UIViewController){
        let _ = taskForGETMethod(host: Constants.AuthorizationHost, pathExtension: Constants.UserPath + user, drop: true) { (result, error) in
            // GUARD: Was there an error?
            guard (error == nil) else {
                self.showErrorMessage(error!, sender)
                return
            }
            guard let result = result as? [String:AnyObject] else {
                return
            }
            guard let userData = result["user"], let firstName = userData["first_name"] as? String, let lastName = userData["last_name"] as? String else {
                return
            }
            UserDefaults.standard.set(firstName, forKey: "USER_FIRST_NAME")
            UserDefaults.standard.set(lastName, forKey: "USER_LAST_NAME")
            UserDefaults.standard.set(user, forKey: "KEY")
        }
    }
    
    /**
     Function used to post a Student location
     
     - Parameter jsonBody: The body for the request.
     - parameter sender: ViewController from which the method was called Used in the cases a message has to be displayed
     - parameter completion: A closure which is called to finish the method call. It indicates if the user has previously posted
     
     */
    func postStudentLocation(_ jsonBody: String, _ sender: UIViewController, completion: @escaping (Bool) -> ()){
        var pathExtension: String
        var method: String
        if objectID != nil{
            pathExtension = "\(Constants.ApiPath)/\(objectID!)"
            method = "PUT"
        }else {
            pathExtension = Constants.ApiPath
            method = "POST"
        }
        
        let _ = taskForPOSTMethod(host: Constants.ApiHost, headers: Constants.PostLocationHeaders, method: method, jsonBody: jsonBody, pathExtension: pathExtension, drop: false) { (result, error) in
            // GUARD: Was there an error?
            
            guard (error == nil) else {
                self.showErrorMessage(error!, sender)
                completion(false)
                return
            }
            completion(true)
        }
    }
}
