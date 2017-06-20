//
//  Student.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation


struct Student {
    
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[UdacityClient.JSONResponseKeys.firstName] as? String ?? ""
        lastName = dictionary[UdacityClient.JSONResponseKeys.lastName] as? String ?? ""
        latitude = dictionary[UdacityClient.JSONResponseKeys.latitude] as? Double ?? 0
        longitude = dictionary[UdacityClient.JSONResponseKeys.longitude] as? Double ?? 0
        mapString = dictionary[UdacityClient.JSONResponseKeys.mapString] as? String ?? ""
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.mediaURL] as? String ?? ""
        objectId = dictionary[UdacityClient.JSONResponseKeys.objectId] as? String ?? ""
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.uniqueKey] as? String ?? ""
    }
    
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [Student] {
        var students = [Student]()
        
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        return students
    }
}



extension Student: Equatable {}

func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.uniqueKey == rhs.uniqueKey
}
