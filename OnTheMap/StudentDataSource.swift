//
//  StudentDataSource.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/28/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation


class StudentDataSource {
    var students = [Student]()
    static let sharedInstance = StudentDataSource()
    private init() {} //This prevents others from using the default '()' initializer for this class.
}
