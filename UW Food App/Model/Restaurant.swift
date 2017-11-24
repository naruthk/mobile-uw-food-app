//
//  Restaurant.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

class Restaurant {
    
    var restaurantID : Int
    var name : String
    var description : String
    var locationName : String
    var fullAddress : String
    var mapCoordinates : [Float]
    var category : String
    var averageRating : Double
    var hours : [[String:String]]
    var contact_name : String
    var contact_email : String
    var contact_phone : String
    var contact_website : String
    
    // Each restaurant may or may not have a menu of food available
    var menus : [Food]?
    
    // Using Google Map Distance Matrix API, we can also instantiate the distance
    // from the user's current location to this particular restaurant's location
    var relativeDistanceFromUserCurrentLocation : String    // Example value: 6.5 mi
    var relativeDurationFromUserCurrentLocation : String    // Example value: 2 hours 7 mins
    
    init(
        restaurantID : Int,
        name: String,
        description: String,
        locationName: String,
        fullAddress: String,
        mapCoordinates: [Float],
        category: String,
        averageRating: Double,
        hours: [[String:String]],
        contact_name: String,
        contact_email: String,
        contact_phone: String,
        contact_website: String,
        menus: [Food],
        relativeDistanceFromUserCurrentLocation : String,
        relativeDurationFromUserCurrentLocation : String) {
        self.restaurantID = restaurantID
        self.name = name
        self.description = description
        self.locationName = locationName
        self.fullAddress = fullAddress
        self.mapCoordinates = mapCoordinates
        self.category = category
        self.averageRating = averageRating
        self.hours = hours
        self.contact_name = contact_name
        self.contact_email = contact_email
        self.contact_phone = contact_phone
        self.contact_website = contact_website
        
        // Each restaurant may or may not have a menu of food available
        self.menus = menus
        
        // Relative distance and walking time
        self.relativeDistanceFromUserCurrentLocation = relativeDistanceFromUserCurrentLocation
        self.relativeDurationFromUserCurrentLocation = relativeDurationFromUserCurrentLocation
    }
}
