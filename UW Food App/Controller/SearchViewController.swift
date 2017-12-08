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
//  SearchViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import SwiftyDrop
import Firebase

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    
    // Shared with the rest of the classes
    var restaurants = SharedInstance.sharedInstance
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var userOriginalLocationParam : [Double] = []
    let locationManager = CLLocationManager()
    let autocompleteController = GMSAutocompleteViewController()
    
    var reviewsItem : [Reviews] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.reviewsItem.removeAll()    // Clear data first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        setMapFilter()
        searchController?.searchBar.placeholder = "Restaurants"
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    // We try to filter the map's data to be as close to what we want as possible. That's why
    // enum "establishment" is used.
    func setMapFilter() {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "usa"
    }
    
    // Begin finding user's current location
    func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Retrieve the user's current location (latitude and longitude)
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
    
    // Return the coordinates of the user's current location to the GMSCoordinateBounds so that
    // Google can fetch results near-by
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

// MARK: - GMSAutocompleteResultsViewControllerDelegate
extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        retrieveReviews(restaurants.restaurantsData[place.placeID]!)
        searchController?.isActive = false
        if let val = restaurants.restaurantsData[place.placeID] {
            let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "MasterDetail") as! MasterDetailViewController
            vc.userData = val
            vc.hoursItem = [
                Information(leftText: "Sun", rightText: val._hours["sun"]!),
                Information(leftText: "Mon", rightText: val._hours["mon"]!),
                Information(leftText: "Tues", rightText: val._hours["tues"]!),
                Information(leftText: "Wed", rightText: val._hours["wed"]!),
                Information(leftText: "Thurs", rightText: val._hours["thurs"]!),
                Information(leftText: "Fri", rightText: val._hours["fri"]!),
                Information(leftText: "Sat", rightText: val._hours["sat"]!)
            ]
            vc.locationsItem = [
                Information(leftText: "Husky Card", rightText: "Yes"),
                Information(leftText: "Debit, Credit Card", rightText: "Yes (VISA, MasterCard)"),
                Information(leftText: "Cash", rightText: "Yes")
            ]
            vc.paymentsItem = [
                Information(leftText: "Husky Card", rightText: "Yes"),
                Information(leftText: "Debit, Credit Card", rightText: "Yes (VISA, MasterCard)"),
                Information(leftText: "Cash", rightText: "Yes")
            ]
            vc.reviewsItem = self.reviewsItem
            let navBarOnVC: UINavigationController = UINavigationController(rootViewController: vc)
            self.present(navBarOnVC, animated: true, completion: nil)
        } else {
            Drop.down("Cannot retrieve information for this restaurant", state: .error)
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
    
    func populateReviews(dictionary: [String: AnyObject]) {
        let message = dictionary["message"] as! String
        let rating = dictionary["rating"] as! String
        let name = dictionary["name"] as! String
        let timestamp = dictionary["timestamp"] as! Double
        let review = Reviews(name: name, rating: rating, message: message, timestamp: timestamp)
        self.reviewsItem.append(review)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
