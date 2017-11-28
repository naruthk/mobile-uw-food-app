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
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewFunctionalities()
        setStatusBarColor()
        setHeader()
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
    
    func setHeader() {
        topHeroView.backgroundColor = colorForOverall
        addToFavoriteButton.setFAIcon(icon: .FABookmarkO, iconSize: 25, forState: .normal)
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
        if !call.isEmpty && call != "-" {
            let url = URL(string: "tel://\(call)")
            UIApplication.shared.open(url!)
        } else {
            Drop.down("Unable to retrieve phone number.", state: .warning)
        }
    }
    
    @IBAction func openMap(_ sender: Any) {
        let restaurantID = userData.restaurantID
        if !restaurantID.isEmpty && restaurantID.count > 3 {
            let url = "https://www.google.com/maps/dir/?api=1&destination=WA&destination_place_id=\(restaurantID)&travelmode=walking"
            UIApplication.shared.openURL(URL(string: url)!)
        } else {
            Drop.down("Unable to retrieve map data", state: .warning)
        }
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        let website = userData.contact_website
        if !website.isEmpty && website != "-" {
            let url = URL(string: website)
            UIApplication.shared.open(url!)
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
