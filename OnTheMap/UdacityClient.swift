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

class UdacityClient: NSObject {
    
    
    // shared session
    var session = URLSession.shared
    
    // create a URL from parameters
    private func udacityURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask{
        
        let headers = ["content-type": "application/json", "Accept" : "application/json"] //as [String:AnyObject]
        //        parameters.forEach {
        //            headers.updateValue($1, forKey: $0)
        //        }
        let request = NSMutableURLRequest(url: URL(string:method)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let sessionData = self.sessionHandler(data, response, error, "taskForPOSTMethod")
            
            guard let data = sessionData.1 else {
                completionHandlerForPOST(nil, sessionData.0)
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
    
    func sessionHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ domain: String) -> (Error?, Data?) {
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
            default:
                errorString = "Your request returned with status code \(statusCode!)!"
            }
            return (createError(errorString), nil)
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            return (createError("No data was returned by the request!"), nil)
        }
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        print(newData)
        return (nil, newData)
    }
    
    // given raw JSON, return a usable Foundation object
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
    
    func showErrorMessage(_ error: Error, _ sender: UIViewController){
        DispatchQueue.main.async(execute: {
            let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            sender.present(controller, animated: true, completion: nil)})
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
