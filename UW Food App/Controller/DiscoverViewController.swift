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

var restaurantsData = [String:Restaurant]()

class DiscoverViewController: UIViewController {
    
    // For Maps
    let locationManager = CLLocationManager()
    var defaultLocation = [47.656059, -122.305047]
    var lastAddedMarker = GMSMarker()
    var userOriginalLocationParam = [Double]()
    
    var searchHistories = [Restaurant]()
    var userData = Restaurant(value: "")
    
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var dateLabelAsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchButton()
        getTodayDate()
        initializeLocationManager()
        setGoogleMapFunctionalities()
        retrieveRestaurantsData()
        cachedData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setSearchButton() {
        searchButton.setFAIcon(icon: .FASearch, iconSize: 25, forState: .normal)
        searchButton.setFATitleColor(color: UIColor.flatGray())
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1;   // Search tab is the index #1
    }
    
    func getTodayDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        let convertedDate = dateFormatter.string(from: currentDate)
        dateLabelAsButton.setTitle(String(convertedDate), for: .normal)
        dateLabelAsButton.tintColor = UIColor.flatGray()
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
                
                // MARK: - Marker created!
                self.createAMarker(
                    userData: restaurant,
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            if let myVC = segue.destination as? MasterDetailViewController {
                let hours = InformationSection(type: "Hours", dataTitles: ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"], dataDetails: [userData.hours["sun"]!, userData.hours["mon"]!, userData.hours["tues"]!, userData.hours["wed"]!, userData.hours["thurs"]!, userData.hours["fri"]!, userData.hours["sat"]!], expanded: true)
                let location = InformationSection(type: "Location", dataTitles: ["Address", "Distance", "Duration"], dataDetails: [userData.locationName, userData.relativeDistanceFromUserCurrentLocation, userData.relativeDurationFromUserCurrentLocation], expanded: false)
                let payment = InformationSection(type: "Payment", dataTitles: ["UW-Only", "Cards"], dataDetails: ["Husky Card", "Debit, Credit (Visa, MasterCard)"], expanded: false)
                myVC.userData = self.userData
                myVC.informationSections = [hours, location, payment]
                myVC.userOriginalLocationParam = userOriginalLocationParam
            }
        }
    }
    
    func cachedData() {
//        let docsBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let customPlistURL = docsBaseURL.appendingPathComponent("restaurants.plist")
//        NSDictionary(dictionary: restaurantsData).write(to: customPlistURL, atomically: true)
    }
}

extension DiscoverViewController: GMSMapViewDelegate {

    func setGoogleMapFunctionalities() {
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
        marker.map = googleMaps
        self.googleMaps.selectedMarker = marker
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let currentRestaurant = marker as GMSMarker
        userData = currentRestaurant.userData as! Restaurant
        self.performSegue(withIdentifier: "goToDetail", sender: self)
    }
}

extension DiscoverViewController: CLLocationManagerDelegate {

    func initializeLocationManager() {
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

