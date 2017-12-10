/// Copyright (c) 2017 UW Food App
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

//
//  DiscoverMapViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyDrop
import ChameleonFramework
import GoogleMaps
import GooglePlaces
import Font_Awesome_Swift
import Firebase
import Alamofire
import SwiftyJSON
import PopupDialog

class DiscoverMapViewController: UIViewController {
    
    // Shared instances are used throughout the whole state of the application
    let googleMapDistanceMatrixAPIKey = SharedInstance.sharedInstance.GOOGLE_MAP_DISTANCE_MATRIX_API_KEY
    let googleMapDistanceURL = SharedInstance.sharedInstance.GOOGLE_MAP_DISTANCE_URL
    var restaurants = SharedInstance.sharedInstance
    var searches = SharedInstance.sharedInstance
    
    // Local private variables
    var savedMarkersDictionary = Dictionary<String, GMSMarker>()
    let locationManager = CLLocationManager()
    var defaultLocation = [47.656059, -122.305047]
    var lastAddedMarker = GMSMarker()
    var userOriginalLocationParam = [Double]()
    var userData = Restaurant(value: "")
    var reviewsItem : [Reviews] = []
    
    // The path to the file stores the caching values for restaurants
    var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return (url!.appendingPathComponent("Data").path)
    }
    
    // For Pulley Card effects to work
    var mapsPadding:UIEdgeInsets {
        get {
            return googleMaps.padding
        }
        set(newPadding) {
            googleMaps.padding = newPadding
        }
    }
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.reviewsItem.removeAll()    // Clear data first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // In case the user (who is already signed in) closes the app, we'll sign the user out first.
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error logging out")
        }
        initializeLocationManager()
        setGoogleMapFunctionalities()
        // If there's NO network connection, then we use the values that are cached!
        if Reachability.isConnectedToNetwork() != true {
            Drop.down("Please check your Internet connection.", state: .error)
            loadData()
        } else {
            retrieveRestaurantsData()
            observeRestaurantsData()
        }
    }

    // Retrieves restaurants data from Firebase (doesn't need the user to be logged in)
    // This method is called only once (when the app first loads)
    func retrieveRestaurantsData() {
        let restaurantsDB = Database.database().reference().child("restaurants")
        restaurantsDB.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.populateRestaurantsData(dictionary: dictionary)
            }
        }) { (error) in
            print("Error retrieving values")
        }
    }
    
    // This method continuously checks for any updated data from the Firebase database.
    // Whenever there's a change, the app reloads the data and saves it to system for offline access
    private func observeRestaurantsData() {
        let restaurantsDB = Database.database().reference().child("restaurants")
        restaurantsDB.observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.populateRestaurantsData(dictionary: dictionary)
            }
        })
    }
    
    // Populates all restaurants data using items fetch by either the "retrieveRestaurantsData" or
    // the "observeRestaurantsData" fu
    private func populateRestaurantsData(dictionary: [String: AnyObject]) {
        guard let id = dictionary["id"] as? String else {
            print("id not found")
            return
        }
        guard let title = dictionary["title"] as? String else {
            print("title not found")
            return
        }
        guard let description = dictionary["description"] as? String else {
            print("description not found")
            return
        }
        guard let address = dictionary["address"] as? String else {
            print("address not found")
            return
        }
        guard let building = dictionary["building"] as? String else {
            print("building not found")
            return
        }
        guard let category = dictionary["category"] as? String else {
            print("category not found")
            return
        }
        guard let average_rating = dictionary["average_rating"] as? String else {
            print("average_rating not found")
            return
        }
        guard let latitude = dictionary["latitude"] as? String else {
            print("latitude not found")
            return
        }
        guard let longitude = dictionary["longitude"] as? String else {
            print("longitude not found")
            return
        }
        guard let contact_name = dictionary["contactInformation"]!["name"] as? String else {
            print("contact_name not found")
            return
        }
        guard let contact_email = dictionary["contactInformation"]!["email"] as? String else {
            print("contact_name not found")
            return
        }
        guard let contact_phone = dictionary["contactInformation"]!["phone"] as? String else {
            print("contact_name not found");
            return
        }
        guard let contact_website = dictionary["contactInformation"]!["website"] as? String else {
            print("contact_name not found");
            return
        }
        guard let hourSun = dictionary["hours"]!["sun"] as? String else {
            print("hourSun not found")
            return
        }
        guard let hourMon = dictionary["hours"]!["mon"] as? String else {
            print("hourMon not found")
            return
        }
        guard let hourTues = dictionary["hours"]!["tues"] as? String else {
            print("hourTues not found")
            return
        }
        guard let hourWed = dictionary["hours"]!["wed"] as? String else {
            print("hourWed not found")
            return
        }
        guard let hourThurs = dictionary["hours"]!["thurs"] as? String else {
            print("hourThurs not found")
            return
        }
        guard let hourFri = dictionary["hours"]!["fri"] as? String else {
            print("hourFri not found")
            return
        }
        guard let hourSat = dictionary["hours"]!["sat"] as? String else {
            print("hourSat not found")
            return
        }
        guard let hours = [
            "sun":hourSun, "mon":hourMon,"tues":hourTues, "wed":hourWed,
            "thurs":hourThurs, "fri":hourFri, "sat":hourSat] as? [String:String] else {
                print("hours cannot be formed")
                return
        }
        
        let restaurant: Restaurant = Restaurant(
            id: id, title: title, description: description, building: building,
            address: address, latitude: latitude, longitude: longitude, category: category,
            average_rating: average_rating, hours: hours, contact_name: contact_name,
            contact_email: contact_email, contact_phone: contact_phone,
            contact_website: contact_website, distance: "-", duration: "-")
        
        guard let todayHours = hours[HelperFunctions().getDayOfToday()] else {
            print("Cannot get today's hours")
            return
        }
        
        // We create a snippet for Google Map to display as markers / pins on the map
        var snippet: String = (average_rating == "0.0") ? "\(category)" : "\(category), \(average_rating)"
        snippet = snippet + " | Today: \(todayHours)"
        self.createAMarker(userData: restaurant, latitude: Double(latitude)!, longitude: Double(longitude)!,
                           title: title, snippet: snippet)
        
        // Saving data to phone's local storage (for offline)
        self.saveData(restaurant: restaurant)
    }
    
    // Saves data to phone's local storage. Essentially caching the restaurants data in a Dictionary.
    private func saveData(restaurant: Restaurant) {
        self.restaurants.restaurantsData[restaurant._id] = restaurant
        userData = restaurant
        NSKeyedArchiver.archiveRootObject(self.restaurants.restaurantsData, toFile: filePath)
    }
    
    // Loads the data. This method only runs if the user cannot connect to the Internet
    private func loadData() {
        if let cachedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String:Restaurant] {
            self.restaurants.restaurantsData = cachedData
        }
        for restaurant in self.restaurants.restaurantsData.values {
            let title = restaurant._title
            let category = restaurant._category
            let average_rating = restaurant._average_rating
            let hours = restaurant._hours
            let latitude = restaurant._latitude
            let longitude = restaurant._longitude
            let todayDate = Date()
            let calendar = Calendar.current
            let day = calendar.component(.weekday, from: todayDate) - 1
            let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
            let snippet = category + ", " + average_rating + " | Today: " + hours[dayValues[day]]!

            self.createAMarker(
                userData: restaurant,
                latitude: Double(latitude)!,
                longitude: Double(longitude)!,
                title: title,
                snippet: snippet)
        }
    }
}

// MARK: - GMSMapViewDelgate
extension DiscoverMapViewController: GMSMapViewDelegate {
    
    private func setGoogleMapFunctionalities() {
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation[0], longitude: defaultLocation[1], zoom: 14.0)
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
    }
    
    func createAMarker(userData: Restaurant, latitude: Double, longitude: Double, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.icon = UIImage(named: "Markers")
        marker.title = title
        marker.snippet = snippet
        marker.userData = userData as Any
        
        // This hack right here checks to see if the map that is currently being displayed contains the marker
        // that requires updating. When a marker recognizies that a new restaurant data has been updated,
        // the marker is deleted and a new marker (with updated data) is replaced.
        if savedMarkersDictionary.keys.contains(marker.title!) {
            let savedMarker : GMSMarker = savedMarkersDictionary[marker.title!]!
            savedMarker.map = nil
        }
        savedMarkersDictionary[marker.title!] = marker
        marker.map = googleMaps
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let currentRestaurant = marker as GMSMarker
        self.populateDistanceAndDuration(currentRestaurant.userData as! Restaurant)
        self.retrieveReviews(currentRestaurant.userData as! Restaurant)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        userData = marker.userData as! Restaurant
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "MasterDetail") as! MasterDetailViewController
        vc.userData = userData
        vc.hoursItem = [
            Information(leftText: "Sun", rightText: userData._hours["sun"]!),
            Information(leftText: "Mon", rightText: userData._hours["mon"]!),
            Information(leftText: "Tues", rightText: userData._hours["tues"]!),
            Information(leftText: "Wed", rightText: userData._hours["wed"]!),
            Information(leftText: "Thurs", rightText: userData._hours["thurs"]!),
            Information(leftText: "Fri", rightText: userData._hours["fri"]!),
            Information(leftText: "Sat", rightText: userData._hours["sat"]!)
        ]
        vc.locationsItem = [
            Information(leftText: "Building", rightText: userData._building),
            Information(leftText: "Walking Distance", rightText: userData._distance),
            Information(leftText: "Walking Duration", rightText: userData._duration)
        ]
        vc.paymentsItem = [
            Information(leftText: "Husky Card", rightText: "Yes"),
            Information(leftText: "Debit, Credit Card", rightText: "Yes (VISA, MasterCard)"),
            Information(leftText: "Cash", rightText: "Yes")
        ]
        vc.reviewsItem = self.reviewsItem
        let navBarOnVC: UINavigationController = UINavigationController(rootViewController: vc)
        self.present(navBarOnVC, animated: true, completion: nil)
    }
    
    // This method fetches the Google Maps API to find out how far the user's walking distance and duration are
    // from the user's destination. Note that this method occurs after initial restaurants data have been
    // fetched. So we update each restaurant's information with the following walking distance and duration
    // at a later point.
    func populateDistanceAndDuration(_ userData: Restaurant) {
        let userOriginsLocation = "\(userOriginalLocationParam[0]),\(userOriginalLocationParam[1])"
        let id = userData._id
        let destination_latitude = userData._latitude
        let destination_longitude = userData._longitude
        let parameters : [String: String] = [
            "origins" : userOriginsLocation,
            "destinations" : "\(destination_latitude),\(destination_longitude)",
            "mode" : "walking",
            "key": googleMapDistanceMatrixAPIKey]
        Alamofire.request(googleMapDistanceURL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                let result : JSON = JSON(response.result.value!)
                for currentElement in result["rows"][0]["elements"].arrayValue {
                    let status = currentElement["status"].string
                    if (status == "OK") {
                        let distance = "\(currentElement["distance"]["text"].string ?? "")"
                        let duration = "\(currentElement["duration"]["text"].string ?? "")"
                        let currentRestaurant = self.restaurants.restaurantsData[id]
                        currentRestaurant?._distance = distance
                        currentRestaurant?._duration = duration
                        self.restaurants.restaurantsData[id] = currentRestaurant
                    }
                }
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func retrieveReviews(_ userData: Restaurant) {
        let reviewsDB = Database.database().reference().child("reviews/\(userData._id)")
        reviewsDB.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.populateReviews(dictionary: dictionary)
            }
        })
    }
    
    // Populates navigation bar titles and today's operating hours
    func populateReviews(dictionary: [String: AnyObject]) {
        let message = dictionary["message"] as! String
        let rating = dictionary["rating"] as! String
        let name = dictionary["name"] as! String
        let timestamp = dictionary["timestamp"] as! Double
        let review = Reviews(name: name, rating: rating, message: message, timestamp: timestamp)
        self.reviewsItem.append(review)
    }
}

// MARK: - CLLocationManagerDelegate
extension DiscoverMapViewController: CLLocationManagerDelegate {
    
    // Begin requesting for the user's current location. Note that desiredAccuracy is set to
    // "kCLLocationAccuracyBest" because we always want to check where the user currently is located
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // LocationManager finds the current location and stores the data in an array of Doubles
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            userOriginalLocationParam.append(Double(location.coordinate.latitude))
            userOriginalLocationParam.append(Double(location.coordinate.longitude))
        }
    }
    
    // If the location cannot be found (i.e., user decides to reject our permission), the app will
    // notify the user immediately
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let title = "Location Access"
        let message = "We are unable to look up your current location. Please make sure that the app is allowed the permission to access your location."
        let popup = PopupDialog(title: title, message: message)
        let close = DefaultButton(title: "Close") {}
        popup.addButton(close)
        self.present(popup, animated: true, completion: nil)
        print(error);
    }
}
