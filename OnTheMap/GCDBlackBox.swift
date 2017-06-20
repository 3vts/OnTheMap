//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Alvaro Santiesteban on 6/18/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
