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

class SearchViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var userOriginalLocationParam : [Double] = []
    let locationManager = CLLocationManager()
    let autocompleteController = GMSAutocompleteViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        
        searchBar.delegate = self
    
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "usa"
        
        // TODO: - Implement Recent Searches
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        autocompleteController.delegate = self
        autocompleteController.autocompleteBounds = getCoordinateBounds(latitude: userOriginalLocationParam[0], longitude: userOriginalLocationParam[1])
        present(autocompleteController, animated: true, completion: nil)
    }

    func setUpSeachHistoriesList() {

    }
    
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
