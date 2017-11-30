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

class MasterDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {

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
    let colorForOverall : UIColor = UIColor.flatPurpleColorDark()
    
    @IBOutlet weak var ratingPanel: CosmosView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var restaurantHours: UILabel!
    @IBOutlet weak var restaurantRatingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewFunctionalities()
        setStatusBarColor()
        populateHeader()
        populateRating()
        populateButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTableViewFunctionalities() {
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
    }
    
    func setStatusBarColor() {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = colorForOverall
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    func populateHeader() {
        self.title = userData.name
        let todayDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: todayDate)
        let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
        let category = String(userData.category).capitalized
        restaurantCategory.text = category
        if (userData.hours[dayValues[day]] != nil) {
            let hoursOfOperationToday = userData.hours[dayValues[day]]
            restaurantHours.text = "\(hoursOfOperationToday ?? "")"
        }
    }
    
    func populateRating() {
        ratingPanel.rating = Double(userData.averageRating)!
        ratingPanel.settings.updateOnTouch = false
        ratingPanel.settings.starMargin = 2
        ratingPanel.settings.filledColor = UIColor.flatGray()
        ratingPanel.settings.emptyBorderColor = UIColor.flatGray()
        ratingPanel.settings.filledBorderColor = UIColor.flatGray()
        restaurantRatingLabel.text = "\(userData.averageRating)"
    }
    
    func populateButtons() {
        saveButton.setFAIcon(icon: .FAStar, iconSize: 30, forState: .normal)
        callButton.setFAIcon(icon: .FAPhone, iconSize: 30, forState: .normal)
        mapsButton.setFAIcon(icon: .FAMap, iconSize: 30, forState: .normal)
        websiteButton.setFAIcon(icon: .FALink, iconSize: 30, forState: .normal)
    }
    
    @IBAction func revealInfoButtonPressed(_ sender: Any) {
        if !userData.restaurantDescription.isEmpty && userData.restaurantDescription != "-" {
            let infoAlert = UIAlertController(title: userData.name, message: userData.restaurantDescription, preferredStyle: UIAlertControllerStyle.alert)
            infoAlert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            self.present(infoAlert, animated: true, completion: nil)
        } else {
            Drop.down("More information not available.", state: .warning)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        favoritesItem.append(userData)
    }
    
    @IBAction func callPhoneNumber(_ sender: Any) {
        let call = userData.contact_phone
        if !call.isEmpty && call != "-" {
            let url = URL(string: "tel://\(call)")
            UIApplication.shared.open(url!)
        } else {
            Drop.down("Unable to retrieve phone number.", state: .warning)
        }
    }
    
    @IBAction func openMap(_ sender: Any) {
        let errorMessage = "Unable to retrieve map data"
        let restaurantID = userData.restaurantID
        if !restaurantID.isEmpty && restaurantID.count > 3 {
            guard let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=WA&destination_place_id=\(restaurantID)&travelmode=walking") else {
                Drop.down(errorMessage, state: .warning)
                return
            }
            let leaveAppAlert = UIAlertController(title: "Leaving the application", message: "Are you sure you want to do so?", preferredStyle: UIAlertControllerStyle.alert)
                
            leaveAppAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            
            leaveAppAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            
            self.present(leaveAppAlert, animated: true, completion: nil)
        } else {
            Drop.down(errorMessage, state: .warning)
        }
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        let website = userData.contact_website
        if !website.isEmpty && website != "-" {
            let url = URL(string: website)
            let leaveAppAlert = UIAlertController(title: "Leaving the application", message: "Are you sure you want to do so?", preferredStyle: UIAlertControllerStyle.alert)
            
            leaveAppAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            
            leaveAppAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                UIApplication.shared.open(url!)
            }))
            self.present(leaveAppAlert, animated: true, completion: nil)
        } else {
            Drop.down("Unable to retrieve website.", state: .warning)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return informationSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informationSections[section].dataDetails.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (informationSections[indexPath.section].expanded) {
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(
            leftText: informationSections[section].type,
            rightText: informationSections[section].type,
            section: section,
            delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
        cell.textLabel?.text = informationSections[indexPath.section].dataTitles[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = informationSections[indexPath.section].dataDetails[indexPath.row]
        return cell
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        informationSections[section].expanded = !informationSections[section].expanded
        tableView.beginUpdates()
        for i in 0 ..< informationSections[section].dataDetails.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }

}
