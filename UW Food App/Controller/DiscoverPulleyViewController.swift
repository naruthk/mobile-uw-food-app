//
//  DiscoverViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 11/28/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Pulley
import Font_Awesome_Swift
import GoogleMaps

class DiscoverPulleyViewController: PulleyViewController {
    
    @IBOutlet var mapView: UIView!
    @IBOutlet var cardView: UICollectionView!
    @IBOutlet weak var dateLabelAsUIBarButtonItem: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    
    var mapViewController: DiscoverMapViewController!
    var cardViewController: DiscoverCardViewController!
    
    var initialPadding:UIEdgeInsets!
    var userData:Restaurant! {
        didSet {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.primaryContentContainerView = mapView
        super.drawerContentContainerView = cardView
        super.drawerCornerRadius = 0
        super.backgroundDimmingColor = .clear
        super.backgroundDimmingOpacity = CGFloat(0)
        super.drawerBackgroundVisualEffectView = nil
        mapViewController = childViewControllers.first as? DiscoverMapViewController
        cardViewController = childViewControllers.last as? DiscoverCardViewController
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTodayDate()
        setSearchButton()
        setMyLocationButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setSearchButton() {
        searchButton.setFAIcon(icon: .FASearch, iconSize: 25, forState: .normal)
        searchButton.setFATitleColor(color: UIColor.flatGray())
    }
    
    private func setMyLocationButton() {
        myLocationButton.setFAIcon(icon: .FALocationArrow, iconSize: 25, forState: .normal)
        myLocationButton.setFATitleColor(color: UIColor.flatGray())
    }
    
    func getTodayDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        let convertedDate = dateFormatter.string(from: currentDate)
        dateLabelAsUIBarButtonItem.setTitle(convertedDate, for: .normal)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1;   // Search tab is the index #1
    }
    
    @IBAction func goToMyLocation(_ sender: Any) {
        if let location = mapViewController.locationManager.location {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
            mapViewController.googleMaps.camera = camera
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}




