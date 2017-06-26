//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import MapKit

class UdacityClient: NSObject {
    
    
    /// Shared session
    var session = URLSession.shared
    
    var region: MKCoordinateRegion? = nil
    
    var objectID: String?
    
    var students = [Student]()
    
    func taskForPOSTMethod(host: String, headers: [String:String], method: String = "POST", jsonBody: String, pathExtension: String? = nil, drop:Bool = true, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask{
        
        var newData: Data? = nil
        let request = NSMutableURLRequest(url: udacityURLFromParameters(host, withPathExtension: pathExtension))
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let sessionData = self.sessionHandler(data, response, error, "taskForPOSTMethod")
            
            guard let data = sessionData.data else {
                completionHandlerForPOST(nil, sessionData.error)
                return
            }
            
            if drop {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            // Parse the data and use the data (happens in completion handler)
            
            self.convertDataWithCompletionHandler(newData ?? data, completionHandlerForConvertData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
    func taskForDeleteMethod(host: String, pathExtension: String, completionHandlerForDelete: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: udacityURLFromParameters(host, withPathExtension: pathExtension))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            let sessionData = self.sessionHandler(data, response, error, "taskForDeleteMethod")
            
            guard let data = sessionData.data else {
                completionHandlerForDelete(nil, sessionData.error)
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            // Parse the data and use the data (happens in completion handler)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDelete)
        }
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(host: String, headers: [String:String]? = nil, parameters: [String:AnyObject]? = nil, pathExtension: String? = nil, drop: Bool = false, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask{
        
        var newData: Data? = nil
        let request = NSMutableURLRequest(url: udacityURLFromParameters(host, parameters, withPathExtension: pathExtension))
        if headers != nil {
            request.allHTTPHeaderFields = headers
        }
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let sessionData = self.sessionHandler(data, response, error, "taskForGETMethod")
            
            guard let data = sessionData.data else {
                completionHandlerForGET(nil, sessionData.error)
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            if drop {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            
            self.convertDataWithCompletionHandler(newData ?? data, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        task.resume()
        
        return task
    }
    
    func sessionHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ domain: String) -> (error: Error?, data: Data?) {

        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            return (createError("There was an error with your request: \(error?.localizedDescription ?? "")", domain), nil)
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            let dataStatus = parseDataStatus(data!)
            return (createError("There was an error with your request: \(dataStatus)", domain), nil)
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            return (createError("No data was returned by the request!", domain), nil)
        }
        
        return (nil, data)
    }
    
    func parseDataStatus(_ data: Data) -> String {
        var newData: Data? = nil
        let statusString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        if statusString.characters.first != "{"{
            let range = Range(5..<data.count)
            newData = data.subdata(in: range)
        }
        
        var parsedResult: [String:AnyObject]! = nil
        do{
            parsedResult = try JSONSerialization.jsonObject(with: newData ?? data, options: .allowFragments) as! [String:AnyObject]
        }catch{
            return ""
        }
        return parsedResult["error"] as! String
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
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
