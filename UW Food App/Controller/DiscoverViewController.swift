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
import SwiftyDrop
import ChameleonFramework
import GoogleMaps
import GooglePlaces

class DiscoverViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    // CONSTANTS
    let DATA_RESTAURANTS_URL = "http://naruthk.com/api/mobile-uw-food-app/data/Restaurants.json"
    let DATA_MENUS_URL = ""
    let DATA_REVIEWS_URL = ""
    let GOOGLE_MAP_DISTANCE_MATRIX_API_KEY = "AIzaSyBCAhnvEa3vyHYp0A_mowFiqzjishhP-xQ"
    let GOOGLE_MAP_DISTANCE_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"
    
    // INSTANCE VARIABLES
    let locationManager = CLLocationManager()
    var restaurantsData = [String:Restaurant]()
    var searchHistories = [Restaurant]()
    var defaultLocation = [47.656059, -122.305047] // UW
    var userOriginalLocationParam = [Double]()
    var userOriginsLocation = ""
    var locationDurationText = ""
    var locationDistanceText = ""
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var todayDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        
        getTodayDate()

        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation[0], longitude: defaultLocation[1], zoom: 15.0)
        
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        
        initializeRestaurantsData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTodayDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        let convertedDate = dateFormatter.string(from: currentDate)
        todayDateLabel.text = String(convertedDate)
    }
    
    // Initializes the View by fetching and populating the map (marking a pin)
    // with each restaurant's data
    func initializeRestaurantsData() {
        Alamofire.request(DATA_RESTAURANTS_URL, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let json : JSON = JSON(response.result.value!)
                let results = json["appData"]["restaurants"]
                for currentRestaurant in results.arrayValue {
                    self.addCurrentRestaurantData(currentRestaurant: currentRestaurant)
                }
            } else {
                Drop.down("Please check your Internet connection.", state: .error)
                print("Error \(String(describing: response.result.error))")
            }
        }
    }

    func addCurrentRestaurantData(currentRestaurant: JSON) {
        if let restaurantID = currentRestaurant["restaurantID"].string
            , let name = currentRestaurant["name"].string
            , let restaurantDescription = currentRestaurant["description"].string
            , let locationName = currentRestaurant["locationName"].string
            , let fullAddress = currentRestaurant["fullAddress"].string
            , let category = currentRestaurant["category"].string
            , let latitude = currentRestaurant["mapCoordinates"]["latitude"].string
            , let longitude = currentRestaurant["mapCoordinates"]["longitude"].string
            , let contact_name = currentRestaurant["contactInformation"]["name"].string
            , let contact_email = currentRestaurant["contactInformation"]["email"].string
            , let contact_phone = currentRestaurant["contactInformation"]["phone"].string
            , let contact_website = currentRestaurant["contactInformation"]["website"].string
            , let hourMon = currentRestaurant["hours"]["mon"].string
            , let hourTues = currentRestaurant["hours"]["tues"].string
            , let hourWed = currentRestaurant["hours"]["wed"].string
            , let hourThurs = currentRestaurant["hours"]["thurs"].string
            , let hourFri = currentRestaurant["hours"]["fri"].string
            , let hourSat = currentRestaurant["hours"]["sat"].string
            , let hourSun = currentRestaurant["hours"]["sun"].string {
            
            var hours: [String:String] = [:]
            hours["mon"] = hourMon
            hours["tues"] = hourTues
            hours["wed"] = hourWed
            hours["thurs"] = hourThurs
            hours["fri"] = hourFri
            hours["sat"] = hourSat
            hours["sun"] = hourSun
            
            let mapCoordinates = [latitude, longitude]
            let averageRating = String(0.0)
            
            let placesClient = GMSPlacesClient.shared()
            placesClient.lookUpPlaceID(restaurantID, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                
                guard let place = place else {
                    print("No place details for \(restaurantID)")
                    return
                }
                
                self.restaurantsData[restaurantID]?.updateRating(newRating: "\(place.rating)")
            })
            
            let restaurant = Restaurant(
                restaurantID: restaurantID,
                name: name,
                restaurantDescription: restaurantDescription,
                locationName: locationName,
                fullAddress: fullAddress,
                mapCoordinates: mapCoordinates,
                category: category,
                averageRating: averageRating,
                hours: hours,
                contact_name: contact_name,
                contact_email: contact_email,
                contact_phone: contact_phone,
                contact_website: contact_website,
                relativeDistanceFromUserCurrentLocation: "-",
                relativeDurationFromUserCurrentLocation: "-")
            
            let snippet = String(category).capitalized
            createAMarker(userData: restaurant, latitude: Double(latitude)!, longitude: Double(longitude)!, title: name, snippet: snippet)

            self.restaurantsData[restaurantID] = restaurant
        }
    }
    
    func createAMarker(userData: Restaurant, latitude: Double, longitude: Double, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.snippet = snippet
        marker.userData = userData as Any
        marker.map = googleMaps
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let currentRestaurant = marker as GMSMarker
        let userData = currentRestaurant.userData as! Restaurant
        let myVC = storyboard?.instantiateViewController(withIdentifier: "MasterDetail") as! MasterDetailViewController
        myVC.userData = userData
        myVC.informationSections = [
            InformationSection(type: "Hours", data: [userData.hours["sun"]!]),
            InformationSection(type: "Location", data: [userData.fullAddress]),
            InformationSection(type: "Payment", data: ["Husky Card", "Credit Card"]),
        ]
        self.present(myVC, animated: true, completion: nil)
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
    
    // MARK: - CLLocation Delagate

    // Determines how far away the user is from nearby restaurants (as specified
    // by our Restaurants.JSON data) in terms of walking distance.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            userOriginalLocationParam.append(Double(location.coordinate.latitude))
            userOriginalLocationParam.append(Double(location.coordinate.longitude))
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            userOriginsLocation = "\(latitude),\(longitude)"
            print("DEBUG: Current location: \(userOriginsLocation)")
//            setRelativeDistancesForEachRestaurant(userOriginsLocation: userOriginsLocation)
        }
    }
    
    func setRelativeDistancesForEachRestaurant(userOriginsLocation: String) {
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
                    Drop.down("Unable to check distances.", state: .warning)
                }
                print("DEBUG: DATA => Data for Restaurant ID \(restaurantID): \(self.restaurantsData[restaurantID]?.description ?? "")")
                print("DEBUG: COMPLETED => End Alomafire session")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Drop.down("Unable to obtain your current location.", state: .warning)
        print(error);
    }

}

