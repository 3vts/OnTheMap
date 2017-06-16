//
//  Student.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation


struct Student {
    
    let createdAt: Date
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: URL
    let objectId: String
    let uniqueKey: Int
    let updatedAt: Date
    
    init(createdAt: Date, firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String, mediaURL: URL, objectId: String, uniqueKey: Int, updatedAt: Date) {
        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.updatedAt = updatedAt
    }
}
