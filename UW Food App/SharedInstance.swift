//
//  SharedInstance.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 12/1/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation
import Firebase

class SharedInstance {
    
    static let sharedInstance = SharedInstance()
    
    var restaurantsData = [String:Restaurant]()

    let GOOGLE_MAP_DISTANCE_MATRIX_API_KEY = "AIzaSyBCAhnvEa3vyHYp0A_mowFiqzjishhP-xQ"
    let GOOGLE_MAP_DISTANCE_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"
    
    private init() {
        
    }

}
