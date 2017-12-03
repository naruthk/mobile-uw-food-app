//
//  Reviews.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 12/3/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

struct Reviews {
    
    var sender: String!
    var rating: String!
    var message: String!
    var timestamp: Double!
    
    init(sender: String, rating: String, message: String, timestamp: Double) {
        self.sender = sender
        self.rating = rating
        self.message = message
        self.timestamp = timestamp
    }
}
