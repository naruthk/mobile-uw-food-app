//
//  Restaurant.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

class Restaurant {
    
    public var description: String { return "Restaurant: \(restaurantID) \(name) \(restaurantDescription) \(locationName) \(fullAddress) \(mapCoordinates) \(category) \(averageRating) \(hours) \(relativeDistanceFromUserCurrentLocation) \(relativeDurationFromUserCurrentLocation) \(contact_name) \(contact_email) \(contact_phone) \(contact_website)" }
    
    var restaurantID : String
    var name : String
    var restaurantDescription : String
    var locationName : String
    var fullAddress : String
    var mapCoordinates : [String]
    var category : String
    var averageRating : String
    var hours : [String:String]
    var contact_name : String
    var contact_email : String
    var contact_phone : String
    var contact_website : String
    
    // Using Google Map Distance Matrix API, we can also instantiate the distance
    // from the user's current location to this particular restaurant's location
    var relativeDistanceFromUserCurrentLocation : String = ""    // Example value: 6.5 mi
    var relativeDurationFromUserCurrentLocation : String = ""    // Example value: 2 hours 7 mins
    
    init(
        restaurantID : String,
        name: String,
        restaurantDescription: String,
        locationName: String,
        fullAddress: String,
        mapCoordinates: [String],
        category: String,
        averageRating: String,
        hours: [String:String],
        contact_name: String,
        contact_email: String,
        contact_phone: String,
        contact_website: String,
        relativeDistanceFromUserCurrentLocation : String,
        relativeDurationFromUserCurrentLocation : String) {
        self.restaurantID = restaurantID
        self.name = name
        self.restaurantDescription = restaurantDescription
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
        
        // Relative distance and walking time
        self.relativeDistanceFromUserCurrentLocation = relativeDistanceFromUserCurrentLocation
        self.relativeDurationFromUserCurrentLocation = relativeDurationFromUserCurrentLocation
    }
    
    func updateRelativeDistancesAndDuration(newDistance: String, newDuration: String) {
        self.relativeDistanceFromUserCurrentLocation = newDistance
        self.relativeDurationFromUserCurrentLocation = newDuration
    }
    
}
