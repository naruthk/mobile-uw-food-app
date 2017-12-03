//
//  HomeViewController.swift
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

class DiscoverMapViewController: UIViewController {
    
    var mapsPadding:UIEdgeInsets {
        get {
            return googleMaps.padding
        }
        set(newPadding) {
            googleMaps.padding = newPadding
        }
    }
    
    let googleMapDistanceMatrixAPIKey = SharedInstance.sharedInstance.GOOGLE_MAP_DISTANCE_MATRIX_API_KEY
    let googleMapDistanceURL = SharedInstance.sharedInstance.GOOGLE_MAP_DISTANCE_URL
    
    var restaurants = SharedInstance.sharedInstance
    var savedMarkersDictionary = Dictionary<String, GMSMarker>()
    var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return (url!.appendingPathComponent("Data").path)
    }
    let locationManager = CLLocationManager()
    var defaultLocation = [47.656059, -122.305047]
    var lastAddedMarker = GMSMarker()
    var userOriginalLocationParam = [Double]()
    var searchHistories = [Restaurant]()
    var userData = Restaurant(value: "")
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchButton()
        checkConnectivityToFirebase()
        initializeLocationManager()
        setGoogleMapFunctionalities()
        if Reachability.isConnectedToNetwork() != true {
            print("No internet connection")
            Drop.down("Please check your Internet connection.", state: .error)
            loadData()
        } else {
            print("App is connected to the Internet")
            retrieveRestaurantsData()
            observeRestaurantsData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func checkConnectivityToFirebase() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { (snapshot) in
            if (snapshot.value != nil) {
                print("App is connected to Firebase console")
            } else {
                print("No internet connection")
                Drop.down("Please check your Internet connection.", state: .error)
            }
        })
    }

    private func setSearchButton() {
        searchButton.setFAIcon(icon: .FASearch, iconSize: 25, forState: .normal)
        searchButton.setFATitleColor(color: UIColor.flatGray())
    }

    func retrieveRestaurantsData() {
        let restaurantsDB = Database.database().reference().child("restaurants")
        restaurantsDB.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.populateRestaurantsData(dictionary: dictionary)
            }
        }) { (error) in
            print("Error retrieving values")
            Drop.down("Please check your Internet connection.", state: .error)
        }
    }
    
    private func observeRestaurantsData() {
        let restaurantsDB = Database.database().reference().child("restaurants")
        restaurantsDB.observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.populateRestaurantsData(dictionary: dictionary)
            }
        })
    }
    
    private func populateRestaurantsData(dictionary: [String: AnyObject]) {
        let id = dictionary["id"] as! String
        let title = dictionary["title"] as! String
        let description = dictionary["description"] as! String
        let building = dictionary["building"] as! String
        let address = dictionary["address"] as! String
        let category = dictionary["category"] as! String
        let average_rating = dictionary["average_rating"] as! String
        let latitude = dictionary["latitude"] as! String
        let longitude = dictionary["longitude"] as! String
        let contact_name = dictionary["contactInformation"]!["name"] as! String
        let contact_email = dictionary["contactInformation"]!["email"] as! String
        let contact_phone = dictionary["contactInformation"]!["phone"] as! String
        let contact_website = dictionary["contactInformation"]!["website"] as! String
        let hourMon = dictionary["hours"]!["mon"] as! String
        let hourTues = dictionary["hours"]!["tues"] as! String
        let hourWed = dictionary["hours"]!["wed"] as! String
        let hourThurs = dictionary["hours"]!["thurs"] as! String
        let hourFri = dictionary["hours"]!["fri"] as! String
        let hourSat = dictionary["hours"]!["sat"] as! String
        let hourSun = dictionary["hours"]!["sun"] as! String
        var hours: [String:String] = [:]
        hours["sun"] = hourSun
        hours["mon"] = hourMon
        hours["tues"] = hourTues
        hours["wed"] = hourWed
        hours["thurs"] = hourThurs
        hours["fri"] = hourFri
        hours["sat"] = hourSat
        
        let restaurant = Restaurant(
            id: id,
            title: title,
            description: description,
            building: building,
            address: address,
            latitude: latitude,
            longitude: longitude,
            category: category,
            average_rating: average_rating,
            hours: hours,
            contact_name: contact_name,
            contact_email: contact_email,
            contact_phone: contact_phone,
            contact_website: contact_website,
            distance: "-",
            duration: "-")
        
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
        
        self.saveData(restaurant: restaurant)
    }
    
    private func saveData(restaurant: Restaurant) {
        self.restaurants.restaurantsData[restaurant._id] = restaurant
        userData = restaurant
        NSKeyedArchiver.archiveRootObject(self.restaurants.restaurantsData, toFile: filePath)
    }
    
    private func loadData() {
        if let cachedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String:Restaurant] {
            self.restaurants.restaurantsData = cachedData
        }
//        for (key, value) in self.restaurants.restaurantsData {
//
//            let category =
//            let todayDate = Date()
//            let calendar = Calendar.current
//            let day = calendar.component(.weekday, from: todayDate) - 1
//            let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
//            let snippet = category + ", " + average_rating + " | Today: " + hours[dayValues[day]]!
//
//            self.createAMarker(
//                userData: restaurant,
//                latitude: Double(latitude)!,
//                longitude: Double(longitude)!,
//                title: title,
//                snippet: snippet)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            if let myVC = segue.destination as? MasterDetailViewController {
                let hours = InformationSection(type: "Hours", dataTitles: ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"], dataDetails: [userData._hours["sun"]!, userData._hours["mon"]!, userData._hours["tues"]!, userData._hours["wed"]!, userData._hours["thurs"]!, userData._hours["fri"]!, userData._hours["sat"]!], expanded: true)
                let location = InformationSection(type: "Location", dataTitles: ["Building", "Walking Distance", "Walking Duration"], dataDetails: [userData._building, userData._distance, userData._duration], expanded: true)
                let payment = InformationSection(type: "Payment", dataTitles: ["Husky Card", "Debit, Credit Cards", "Cash"], dataDetails: ["Yes", "Yes (Visa, MasterCard)", "Yes"], expanded: true)
                myVC.userData = self.userData
                myVC.informationSections = [hours, location, payment]
            }
        }
    }
}

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
        marker.title = title
        marker.snippet = snippet
        marker.userData = userData as Any
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
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        userData = marker.userData as! Restaurant
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
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
}

extension DiscoverMapViewController: CLLocationManagerDelegate {
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            userOriginalLocationParam.append(Double(location.coordinate.latitude))
            userOriginalLocationParam.append(Double(location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Drop.down("Unable to obtain your current location.", state: .warning)
        print(error);
    }
}
