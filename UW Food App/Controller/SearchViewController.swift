//
//  MapViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import SwiftyDrop

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var userOriginalLocationParam : [Double] = []
    let locationManager = CLLocationManager()
    let autocompleteController = GMSAutocompleteViewController()
    
    var searchHistory : [String] = []       // Array of IDs of each restaurant
    
    override func viewDidAppear(_ animated: Bool) {
        searchController?.isActive = true
        searchController?.searchBar.becomeFirstResponder()
        searchController?.searchBar.placeholder = "Restaurants"

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "usa"
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }

    func setUpSeachHistoriesList() {
        
    }
    
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
            let latitude = Double(location.coordinate.latitude)
            let longitude = Double(location.coordinate.longitude)
            userOriginalLocationParam.append(latitude)
            userOriginalLocationParam.append(longitude)
        }
    }
    
    func getCoordinateBounds(latitude: CLLocationDegrees,
                             longitude: CLLocationDegrees,
                             distance: Double = 0.0001) -> GMSCoordinateBounds {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + distance, longitude: center.longitude + distance)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - distance, longitude: center.longitude - distance)
        return GMSCoordinateBounds(coordinate: northEast,
                                   coordinate: southWest)
    }
    
    func updateCoordinateBoundsOnAutoCompleteController() {
        autocompleteController.viewWillAppear(true)
        autocompleteController.viewDidAppear(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        autocompleteController.autocompleteBounds = getCoordinateBounds(latitude: userOriginalLocationParam[0], longitude: userOriginalLocationParam[1])
    }
    
}

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        searchHistory.append("\(place.placeID)")
         // TODO: Keep the history after the user closes the app
        print("\(place.placeID)")
        
        if let val = restaurantsData[place.placeID] {
            openMasterDetailViewScreen(val: val)
        } else {
            Drop.down("Cannot retrieve information for this restaurant", state: .error)
        }
    }
    
    func openMasterDetailViewScreen(val: Restaurant) {
//        let userData = val
//        let myVC = storyboard?.instantiateViewController(withIdentifier: "MasterDetail") as! MasterDetailViewController
//        myVC.userData = userData
//        myVC.informationSections = [
//            InformationSection(type: "Hours",
//                               dataTitles: [
//                                "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"
//                ],
//                               dataDetails: [
//                                userData.hours["sun"]!,
//                                userData.hours["mon"]!,
//                                userData.hours["tues"]!,
//                                userData.hours["wed"]!,
//                                userData.hours["thurs"]!,
//                                userData.hours["fri"]!,
//                                userData.hours["sat"]!
//                ],
//                               expanded: true),
//            InformationSection(type: "Location",
//                               dataTitles: [
//                                "Address", "Distance", "Duration"
//                ],
//                               dataDetails: [
//                                userData.locationName,
//                                userData.relativeDistanceFromUserCurrentLocation,
//                                userData.relativeDurationFromUserCurrentLocation
//                ],
//                               expanded: false),
//            InformationSection(type: "Payment",
//                               dataTitles: [
//                                "UW-Only", "Cards"
//                ],
//                               dataDetails: ["Husky Card", "Debit, Credit (Visa, MasterCard)"], expanded: false),
//        ]
//        self.present(myVC, animated: true, completion: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
