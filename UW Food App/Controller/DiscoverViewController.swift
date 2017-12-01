//
//  HomeViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import CoreLocation
//import Alamofire
//import SwiftyJSON
import SwiftyDrop
import ChameleonFramework
import GoogleMaps
import GooglePlaces
import Font_Awesome_Swift
import Firebase

// Global !!
var restaurantsData = [String:Restaurant]()
var favoritesItem = [String:Restaurant]()
var userOriginsLocation = ""
var userOriginalLocationParam = [Double]()

class DiscoverViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // INSTANCE VARIABLES
    let locationManager = CLLocationManager()
    var searchHistories = [Restaurant]()
    var defaultLocation = [47.656059, -122.305047] // UW
    var locationDurationText = ""
    var locationDistanceText = ""
    var lastAddedMarker = GMSMarker()
    var userData = Restaurant(restaurantID: "", name: "", restaurantDescription: "", locationName: "", fullAddress: "", mapCoordinates: [""], category: "", averageRating: "", hours: ["" : ""], contact_name: "", contact_email: "", contact_phone: "", contact_website: "", relativeDistanceFromUserCurrentLocation: "", relativeDurationFromUserCurrentLocation: "")
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var dateLabelAsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.setFAIcon(icon: .FASearch, iconSize: 25, forState: .normal)
        searchButton.setFATitleColor(color: UIColor.flatGray())
        initializeLocationManager()
        getTodayDate()
        setGoogleMapFunctionalities()
        retrieveRestaurantsData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTodayDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        let convertedDate = dateFormatter.string(from: currentDate)
        dateLabelAsButton.setTitle(String(convertedDate), for: .normal)
        dateLabelAsButton.tintColor = UIColor.flatGray()
    }
    
    func setGoogleMapFunctionalities() {
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation[0], longitude: defaultLocation[1], zoom: 14.0)
        self.googleMaps.camera = camera
        self.googleMaps.delegate = self
        self.googleMaps?.isMyLocationEnabled = true
        self.googleMaps.settings.myLocationButton = true
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
    }

    @IBAction func searchButtonClicked(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1;   // Search tab is the index #1
    }
    
    func retrieveRestaurantsData() {
        let restaurantsDB = Database.database().reference().child("restaurants")
        restaurantsDB.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let restaurantID = dictionary["id"] as! String
                let name = dictionary["name"] as! String
                let restaurantDescription = dictionary["description"] as! String
                let locationName = dictionary["locationName"] as! String
                let fullAddress = dictionary["fullAddress"] as! String
                let category = dictionary["category"] as! String
                let averageRating = dictionary["averageRating"] as! String
                let latitude = dictionary["mapCoordinates"]!["latitude"] as! String
                let longitude = dictionary["mapCoordinates"]!["longitude"] as! String
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
                hours["mon"] = hourMon
                hours["tues"] = hourTues
                hours["wed"] = hourWed
                hours["thurs"] = hourThurs
                hours["fri"] = hourFri
                hours["sat"] = hourSat
                hours["sun"] = hourSun
                let mapCoordinates = [latitude, longitude]
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
                let todayDate = Date()
                let calendar = Calendar.current
                let day = calendar.component(.weekday, from: todayDate)
                let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
                let snippet = String(category).capitalized + ", \(hours[dayValues[day]] ?? "")"
                self.createAMarker(
                    userData:  restaurant,
                    latitude: Double(latitude)!,
                    longitude: Double(longitude)!,
                    title: name,
                    snippet: snippet)
                restaurantsData[restaurantID] = restaurant
            }
        }) { (error) in
            print("Error retrieving values")
            Drop.down("Please check your Internet connection.", state: .error)
        }
    }

    func createAMarker(userData: Restaurant, latitude: Double, longitude: Double, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.snippet = snippet
        marker.userData = userData as Any
        marker.map = googleMaps
        self.googleMaps.selectedMarker = marker
    }

    // MARK: - GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let currentRestaurant = marker as GMSMarker
        userData = currentRestaurant.userData as! Restaurant
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            if let myVC = segue.destination as? MasterDetailViewController {
                myVC.userData = self.userData
                myVC.informationSections = [
                    InformationSection(type: "Hours",
                                       dataTitles: [
                                        "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"
                        ],
                                       dataDetails: [
                                        userData.hours["sun"]!,
                                        userData.hours["mon"]!,
                                        userData.hours["tues"]!,
                                        userData.hours["wed"]!,
                                        userData.hours["thurs"]!,
                                        userData.hours["fri"]!,
                                        userData.hours["sat"]!
                        ],
                                       expanded: true),
                    InformationSection(type: "Location",
                                       dataTitles: [
                                        "Address", "Distance", "Duration"
                        ],
                                       dataDetails: [
                                        userData.locationName,
                                        userData.relativeDistanceFromUserCurrentLocation,
                                        userData.relativeDurationFromUserCurrentLocation
                        ],
                                       expanded: false),
                    InformationSection(type: "Payment",
                                       dataTitles: [
                                        "UW-Only", "Cards"
                        ],
                                       dataDetails: ["Husky Card", "Debit, Credit (Visa, MasterCard)"], expanded: false),
                ]
            }
        }
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
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Drop.down("Unable to obtain your current location.", state: .warning)
        print(error);
    }

}

