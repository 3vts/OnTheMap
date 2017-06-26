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
    
    /// Region used to store the pinned location
    var region: MKCoordinateRegion? = nil
    
    /// String used to store the objectID in case of a previously posted location
    var objectID: String?
    
    /// Student array used to store the information of all the pins retrieved from the server
    var students = [Student]()
    
    /**
     Function to PUT or POST to the RESTful service
     
     - parameter host: URL Host for the request
     - parameter headers: Headers for the request
     - parameter method: String that indicates if the method is going to be used to POST (default) or PUT
     - parameter jsonBody: String containing the httpBody for the request
     - parameter pathExtension: Path for the URL request
     - parameter drop: Boolean indication if the response has to create a subset of the response data
     - parameter completionHandlerForPOST: A closure which is called to finish the method call
     - parameter result: The result of the call
     - parameter error: The error of the call
     
     */
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
    
    
    /**
     Function to DELETE from the RESTful service
     
     - parameter host: URL Host for the request
     - parameter pathExtension: Path for the URL request
     - parameter drop: Boolean indication if the response has to create a subset of the response data
     - parameter completionHandlerForDelete: A closure which is called to finish the method call
     - parameter result: The result of the call
     - parameter error: The error of the call
     
     */
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
    
    /**
     Function to GET from the RESTful service
     
     - parameter host: URL Host for the request
     - parameter headers: Headers for the request
     - parameter parameters: Parameters for the request
     - parameter method: String that indicates if the method is going to be used to POST (default) or PUT
     - parameter pathExtension: Path for the URL request
     - parameter drop: Boolean indication if the response has to create a subset of the response data
     - parameter completionHandlerForGET: A closure which is called to finish the method call
     - parameter result: The result of the call
     - parameter error: The error of the call
     
     */
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
    
    
    /**
     Function to handle the response from the requests
     
     - parameter data: Data received from the request
     - parameter response: Server response
     - parameter error: The error of the call
     - parameter domain: Domain in which the function was called (used in the cases an error has to be created)
     - returns: A tuple containg the data already parsed and the error returned from the parsing (if any)
     
     */
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
    
    /**
     Function to parse the data received from the requests and return the error given
     
     - parameter data: Data received from the request
     - returns: A string containing the server error
     
     */
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
