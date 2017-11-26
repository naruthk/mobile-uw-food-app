//
//  HomeViewController.swift
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
    var restaurantsData = [String:Restaurant]()
    var userOriginsLocation = ""
    var locationDurationText = ""
    var locationDistanceText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeRestaurantsData()
        // initializeLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Initializes the View by fetching and populating view with each restaurant's data
    func initializeRestaurantsData() {
        print("DEBUG: START => Fetching JSON for Restaurants")
        Alamofire.request(DATA_RESTAURANTS_URL, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let json : JSON = JSON(response.result.value!)
                print("DEBUG: Length of results: \(json.count)")
                let results = json["appData"]["restaurants"]
                for currentRestaurant in results.arrayValue {
                    let restaurantID = currentRestaurant["restaurantID"].string
                    let restaurant = self.fetchCurrentRestaurantData(currentRestaurant: currentRestaurant)
                    self.restaurantsData[restaurantID!] = restaurant
                }
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }

    func fetchCurrentRestaurantData(currentRestaurant: JSON) -> Restaurant {
        let restaurantID = currentRestaurant["restaurantID"].string
        print("DEBUG: START => Fetching data of restaurant ID \(restaurantID ?? "")")
        let name = currentRestaurant["name"].string
        let restaurantDescription = currentRestaurant["description"].string
        let locationName = currentRestaurant["locationName"].string
        let fullAddress = currentRestaurant["fullAddress"].string
        let category = currentRestaurant["category"].string
        let averageRating = currentRestaurant["averageRating"].string
        let latitude = "\(currentRestaurant["mapCoordinates"]["latitude"].string ?? "")"
        let longitude = "\(currentRestaurant["mapCoordinates"]["longitude"].string ?? "")"
        let mapCoordinates = [latitude, longitude] as [String]
        let contact_name = currentRestaurant["contactInformation"]["name"].string
        let contact_email = currentRestaurant["contactInformation"]["email"].string
        let contact_phone = currentRestaurant["contactInformation"]["phone"].string
        let contact_website = currentRestaurant["contactInformation"]["website"].string
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
        
        let restaurant = Restaurant(
            restaurantID: restaurantID!,
            name: name!,
            restaurantDescription: restaurantDescription!,
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
            relativeDistanceFromUserCurrentLocation: "-",
            relativeDurationFromUserCurrentLocation: "-")
        
        print("DEBUG: END => Completed fetching data of current restaurant")
        print("DEBUG: DATA => \(restaurant.description)")
        print("DEBUG: --------")
        
        return restaurant
    }
    
    // LocationManager finds out where the user's location is. It asks for the user's permission
    // to get access to the phone's GPS system. Once permission is given, it looks up the current
    // location (best accuracy location) -- note that this drains the battery!
    func initializeLocationManager() {
        print("DEBUG: START => Looking up current location")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    // Determines how far away the user is from nearby restaurants (as specified
    // by our Restaurants.JSON data) in terms of walking distance.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            userOriginsLocation = "\(latitude),\(longitude)"
            print("DEBUG: END => Found current location: \(userOriginsLocation)")
            
            setRelativeDistancesForEachRestaurant(userOriginsLocation: userOriginsLocation)
        }
    }
    
    func setRelativeDistancesForEachRestaurant(userOriginsLocation: String) {
        print("DEBUG: START => Trying to set relative distances for each restaurant. There are \(restaurantsData.values.count) total.")
        for restaurant in restaurantsData.values {
            print("DEBUG: Setting values for restaurant ID \(restaurant.restaurantID)")
            let restaurantID = restaurant.restaurantID
            let latitude = restaurant.mapCoordinates[0]
            let longitude = restaurant.mapCoordinates[1]
            let parameters : [String: String] = [
                "origins" : userOriginsLocation,
                "destinations" : "\(latitude),\(longitude)",
                "mode" : "walking",
                "key": GOOGLE_MAP_DISTANCE_MATRIX_API_KEY]
            
            Alamofire.request(GOOGLE_MAP_DISTANCE_URL, method: .get, parameters: parameters).responseJSON { response in
                if response.result.isSuccess {
                    print("DEBUG: START => Obtaining data from Google Map Distance API")
                    let result : JSON = JSON(response.result.value!)
                    for currentElement in result["rows"][0]["elements"].arrayValue {
                        let status = currentElement["status"].string
                        print("DEBUG: CHECK => API status - \(status ?? "")")
                        if (status == "OK") {
                            print("DEBUG: PROGRESS => Updating current restaurant object with new relative distancea and duration")
                            let locationDistance = "\(currentElement["distance"]["text"].string ?? "")"
                            let locationDuration = "\(currentElement["duration"]["text"].string ?? "")"
                            self.restaurantsData[restaurantID]?.updateRelativeDistancesAndDuration(newDistance: locationDistance, newDuration: locationDuration)
                            print("DEBUG: END => Restaurant ID \(restaurantID) has been updated")
                        } else {
                            self.locationDistanceText = "-"
                            self.locationDurationText = "-"
                        }
                    }
                } else {
                    print("Error \(String(describing: response.result.error))")
                }
                print("DEBUG: DATA => Data for Restaurant ID \(restaurantID): \(self.restaurantsData[restaurantID]?.description ?? "")")
                print("DEBUG: COMPLETED => End Alomafire session")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }

}

