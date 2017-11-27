//
//  MasterDetailViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/26/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import ChameleonFramework
import Font_Awesome_Swift
import Cosmos
import SwiftyDrop

class MasterDetailViewController: UIViewController {

    var userData : Restaurant = Restaurant(
        restaurantID: "-",
        name: "-",
        restaurantDescription: "-",
        locationName: "-",
        fullAddress: "-",
        mapCoordinates: ["-"],
        category: "-",
        averageRating: "-",
        hours: ["-":"-"],
        contact_name: "-",
        contact_email: "-",
        contact_phone: "-",
        contact_website: "-",
        relativeDistanceFromUserCurrentLocation: "-",
        relativeDurationFromUserCurrentLocation: "-")
    
    var informationSections : [InformationSection] = []
    
    var videos: [String] = ["Feee", "eee", "eeee", "eee"]
    
    @IBOutlet weak var topHeroView: UIView!
    @IBOutlet weak var restaurantTitleLabel: UILabel!
    @IBOutlet weak var restaurantShortInformationLabel: UILabel!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ratingPanel: CosmosView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHeaderBackground()

        addToFavoriteButton.setFAIcon(icon: .FABookmarkO, iconSize: 25, forState: .normal)
        
        populateHeader()
        
        populateRating()
        
        populateButtons()
        
        print(informationSections.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setHeaderBackground() {
        topHeroView.backgroundColor = UIColor.flatPurpleColorDark()
    }
    
    func populateHeader() {
        restaurantTitleLabel.text = userData.name
        let todayDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: todayDate)
        let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
        let category = String(userData.category).capitalized
        if (userData.hours[dayValues[day]] != nil) {
            let hoursOfOperationToday = userData.hours[dayValues[day]]
            restaurantShortInformationLabel.text = "\(category) | Today's Hours: \(hoursOfOperationToday ?? "")"
        } else {
            restaurantShortInformationLabel.text = "\(category)"
        }
    }
    
    func populateRating() {
        ratingPanel.rating = Double(userData.averageRating)!
        ratingPanel.settings.updateOnTouch = false
        ratingPanel.settings.starMargin = 2
        ratingPanel.settings.filledColor = UIColor.flatGray()
        ratingPanel.settings.emptyBorderColor = UIColor.flatGray()
        ratingPanel.settings.filledBorderColor = UIColor.flatGray()
        ratingPanel.text = "\(userData.averageRating)"
    }
    
    func populateButtons() {
        menuButton.setFAIcon(icon: .FABook, iconSize: 40, forState: .normal)
        callButton.setFAIcon(icon: .FAPhone, iconSize: 40, forState: .normal)
        mapsButton.setFAIcon(icon: .FAMap, iconSize: 40, forState: .normal)
        websiteButton.setFAIcon(icon: .FALink, iconSize: 40, forState: .normal)
    }
    
    @IBAction func backToDiscoveryButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToFavoriteButton(_ sender: Any) {
    
    }
    
    @IBAction func callPhoneNumber(_ sender: Any) {
        let call = userData.contact_phone
        if !call.isEmpty {
            let url = URL(string: "tel://\(call)")
            UIApplication.shared.open(url!)
        }
    }
    
    @IBAction func openMap(_ sender: Any) {
        let restaurantID = userData.restaurantID
        let url = "https://www.google.com/maps/dir/?api=1&destination=WA&destination_place_id=\(restaurantID)&travelmode=walking"
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        let website = userData.contact_website
        if website != "-" && !website.isEmpty {
            let url = URL(string: website)
            UIApplication.shared.open(url!)
        } else {
            Drop.down("This restaurant has no website.", state: .warning)
        }
    }
    
    

}
