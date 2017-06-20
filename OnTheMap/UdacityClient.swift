//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import MapKit

class UdacityClient: NSObject {
    
    
    /// Shared session
    var session = URLSession.shared
    
    var region: MKCoordinateRegion? = nil
    
    
    var students = [Student]()
    
    // create a URL from parameters
    private func udacityURLFromParameters(_ host: String, _ parameters: [String:AnyObject]? = nil, withPathExtension: String? = nil) -> URL {
        
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
    
    func taskForPOSTMethod(method: String, headers: [String:String],  jsonBody: String, pathExtension: String? = nil, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask{
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(method, withPathExtension: pathExtension))
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let sessionData = self.sessionHandler(data, response, error, "taskForPOSTMethod")
            
            guard let data = sessionData.data else {
                completionHandlerForPOST(nil, sessionData.error)
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            // Parse the data and use the data (happens in completion handler)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(method: String, headers: [String:String], parameters: [String:AnyObject], pathExtension: String? = nil, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask{
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(method, parameters, withPathExtension: pathExtension))
        request.allHTTPHeaderFields = headers
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let sessionData = self.sessionHandler(data, response, error, "taskForGETMethod")
            
            guard let data = sessionData.data else {
                completionHandlerForGET(nil, sessionData.error)
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        task.resume()
        
        return task
    }
    
    
    func sessionHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ domain: String) -> (error: Error?, data: Data?) {
        func createError(_ error: String) -> Error {
            let userInfo = [NSLocalizedDescriptionKey : error]
            return NSError(domain: domain, code: 1, userInfo: userInfo)
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            return (createError("There was an error with your request: \(error!)"), nil)
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            var errorString: String!
            switch statusCode! {
            case 403:
                errorString = "Account not found or invalid credentials"
            case 400:
                errorString = "Username and Password fields are required"
            case 502:
                errorString = "Error retrieving Facebook user with token"
            default:
                errorString = "Your request returned with status code \(statusCode!)!"
            }
            return (createError(errorString), nil)
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            return (createError("No data was returned by the request!"), nil)
        }
        
        return (nil, data)
    }
    
    /// Given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
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
        
        let _ = taskForGETMethod(method: Constants.ApiHost, headers: Constants.ApiHeaders, parameters:  methodParameters, pathExtension:  Constants.ApiPath) { (result, error) in
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
            let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            sender.present(controller, animated: true, completion: nil)
        }
    }
    
    func logout(_ sender: UIViewController) {
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
        }
        let loginViewController = sender.storyboard?.instantiateViewController(withIdentifier: "login")
        UIApplication.shared.keyWindow?.rootViewController = loginViewController
        sender.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
