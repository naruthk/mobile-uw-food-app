//
//  ViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    // CONSTANTS
    let DATA_RESTAURANTS_URL = "http://naruthk.com/api/mobile-uw-food-app/data/Restaurants.json"
    let DATA_MENUS_URL = ""
    let DATA_REVIEWS_URL = ""
    let GOOGLE_MAP_DISTANCE_MATRIX_API_KEY = "AIzaSyBCAhnvEa3vyHYp0A_mowFiqzjishhP-xQ"
    let GOOGLE_MAP_DISTANCE_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"
    
    // INSTANCE VARIABLES
    let locationManager = CLLocationManager()
    var restaurantsData = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // LocationManager finds out where the user's location is. It asks for the user's permission
    // to get access to the phone's GPS system. Once permission is given, it looks up the current
    // location (best accuracy location) -- note that this drains the battery!
    func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Fetches information of all restaurants and also look up a distance from the user's current
    // location and each restaurant's location using the Google Map Distance Matrix API. This method
    // also appends each Restaurant object to the global "restaurantsData" List.
    func initializeRestaurantsData(url: String, userOriginsLocation: String) {
        
        // Retrieve Restaurants.JSON Data using Alamo
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                
                let restaurantsJSON : JSON = JSON(response.result.value!)
                self.updateRestaurantsData(json: restaurantsJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                // TODO: Alert the user that the connection is offline
                
            }
        }
        
        
        
        
//        let parameters : [String: String] = [
//            "origins" : userOriginsLocation,
//            "destinations" : "",
//            "mode" : "walking",
//            "key": GOOGLE_MAP_DISTANCE_MATRIX_API_KEY]
//
//        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
//            response in
//            if response.result.isSuccess {
//                // TODO #2: For each restaurant's latitude and longtitude coordinates,
//                // set parameter "destinations" in variable "params"
//
//                // TODO #3: Add each restaurant to the "restaurantsData" list
//            } else {
//
//            }
//        }
        
    }
    
    // This method looks up information of each restaurant inside the JSON object and append each restaurant
    // data to the global list.
    func updateRestaurantsData(json : JSON) {
        let results = json["appData"]["restaurants"]
        for currentRestaurant in results.arrayValue {
            let restaurantID = currentRestaurant["id"].int
            let name = currentRestaurant["name"].string
            let description = currentRestaurant["description"].string
            let locationName = currentRestaurant["locationName"].string
            let fullAddress = currentRestaurant["fullAddress"].string
            let mapCoordinates = [currentRestaurant["mapCoordinates"][0].float, currentRestaurant["mapCoordinates"][1].float] as! [Float]
            var category = currentRestaurant["category"].string
            let averageRating = currentRestaurant["averageRating"].double
            let hourMon = currentRestaurant["hours"]["mon"].string
            let hourTues = currentRestaurant["hours"]["tues"].string
            let hourWed = currentRestaurant["hours"]["wed"].string
            let hourThurs = currentRestaurant["hours"]["thurs"].string
            let hourFri = currentRestaurant["hours"]["fri"].string
            let hourSat = currentRestaurant["hours"]["sat"].string
            let hourSun = currentRestaurant["hours"]["sun"].string
            
            var hours: [[String:String]] = []
            hours.append(["mon": hourMon!])
            hours.append(["tues": hourTues!])
            hours.append(["wed": hourWed!])
            hours.append(["thurs": hourThurs!])
            hours.append(["fri": hourFri!])
            hours.append(["sat": hourSat!])
            hours.append(["sun": hourSun!])

            let contact_name = currentRestaurant["contactInformation"]["name"].string
            let contact_email = currentRestaurant["contactInformation"]["email"].string
            let contact_phone = currentRestaurant["contactInformation"]["phone"].string
            let contact_website = currentRestaurant["contactInformation"]["website"].string
            
            let menus = [Food(name : "", price : 0.0, category : "")]
            
            let relativeDistanceFromUserCurrentLocation = "-"
            let relativeDurationFromUserCurrentLocation = "-"

            let restaurant = Restaurant(
                restaurantID: restaurantID!,
                name: name!,
                description: description!,
                locationName: locationName!,
                fullAddress: fullAddress!,
                mapCoordinates: mapCoordinates,
                category: category!,
                averageRating: averageRating!,
                hours: hours,
                contact_name: contact_name!,
                contact_email: contact_email!,
                contact_phone: contact_phone!,
                contact_website: contact_website!,
                menus: menus,
                relativeDistanceFromUserCurrentLocation: relativeDistanceFromUserCurrentLocation,
                relativeDurationFromUserCurrentLocation: relativeDurationFromUserCurrentLocation)
            
            restaurantsData.append(restaurant)
        }
    }

    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    // Determines how far away the user is from nearby restaurants (as specified
    // by our Restaurants.JSON data) in terms of walking distance.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil  // We want to retrieve the data only once!
            
            // 1. Get user's current location
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            print("User's current location is at latitude = \(latitude), longitude = \(longitude)")
            
            let userOriginsLocation = "\(latitude),\(longitude)"
            
            // 2. Setup each restaurant's data (including calculating the distances between
            // the user's current location and each near-by restaurant)
            initializeRestaurantsData(url: DATA_RESTAURANTS_URL, userOriginsLocation: userOriginsLocation)

            
        }
    }
    
    // Report an error if we cannot find the user's location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
        // TODO: Show some alert to the user
        
    }


}

