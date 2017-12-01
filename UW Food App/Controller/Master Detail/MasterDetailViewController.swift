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
import Alamofire
import SwiftyJSON
import Firebase

var favoritesItemDictionary = [String:Restaurant]()

class MasterDetailViewController: UIViewController {
    
    let GOOGLE_MAP_DISTANCE_MATRIX_API_KEY = "AIzaSyBCAhnvEa3vyHYp0A_mowFiqzjishhP-xQ"
    let GOOGLE_MAP_DISTANCE_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"

    var userData : Restaurant = Restaurant(value: "")
    var informationSections : [InformationSection] = []
    let colorForOverall : UIColor = UIColor.flatPurpleColorDark()
    var isChecked = false
    var userOriginalLocationParam = [Double]()

    @IBOutlet weak var ratingPanel: CosmosView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var restaurantHours: UILabel!
    @IBOutlet weak var restaurantRatingLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewFunctionalities()
        setStatusBarColor()
        populateHeader()
        populateRating()
        populateButtons()
        setRelativeDistancesForEachRestaurant()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setTableViewFunctionalities() {
        tableView.separatorStyle = .none
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
        let user = Auth.auth().currentUser
        if user != nil {
            let usersRef = Database.database().reference().child("Users")
            let currentUser = usersRef.child("\(user?.uid ?? "")")
            let favoritesItem = currentUser.child("favorites")
            favoritesItem.observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let restaurantID = dictionary["restaurantID"] as! String
                    if restaurantID == self.userData.restaurantID {
                        self.saveButton.setFATitleColor(color: UIColor.flatGray())
                        self.saveButtonLabel.text = "Unsaved"
                    } else {
                        self.saveButton.setFATitleColor(color: UIColor.init(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0))
                        self.saveButtonLabel.text = "Saved"
                    }
                }
            }) { (error) in
                print("Error retrieving values")
            }
        } else {
            if favoritesItemDictionary.keys.contains(userData.restaurantID) {
                self.saveButton.setFATitleColor(color: UIColor.flatGray())
            } else {
                self.saveButton.setFATitleColor(color: UIColor.init(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0))
            }
        }
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
//        let user = Auth.auth().currentUser
//        if user != nil {
//            let usersRef = Database.database().reference().child("Users")
//            let currentUserRef = usersRef.child("\(user?.uid ?? "")")
//            let favoritesItem = currentUserRef.child("favorites")
//            if usersRef != nil {
//                favoritesItem.observe(.childAdded, with: { (snapshot) in
//                    if let dictionary = snapshot.value as? [String: AnyObject] {
//                        let restaurantID = dictionary["restaurantID"] as! String
//                        if restaurantID == self.userData.restaurantID {
//                            self.saveButton.setFATitleColor(color: UIColor.init(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0))
//                            self.saveButtonLabel.text = "Saved"
//                            favoritesItem.child(self.userData.restaurantID).removeValue { error, _ in
//                                if error != nil {
//                                    print("error \(error)")
//                                } else {
//                                    print("Removed from firebase too!")
//                                    favoritesItemDictionary[self.userData.restaurantID] = nil
//                                    Drop.down("Removed \(self.userData.name) from Favorites!", state: .success)
//                                }
//                            }
//                        } else {
//                            self.saveButton.setFATitleColor(color: UIColor.flatGray())
//                            self.saveButtonLabel.text = "Unsaved"
//                            let dictionaryData = [
//                                "autoID" : favoritesItem.key,
//                                "restaurantName" : self.userData.name,
//                                "restaurantID" : self.userData.restaurantID
//                            ]
//                            favoritesItem.childByAutoId().setValue(dictionaryData)
//                            favoritesItemDictionary[self.userData.restaurantID] = self.userData
//                            print("Added to Favorites")
//                            Drop.down("Added \(self.userData.name) to Favorites!", state: .success)
//                        }
//                    } else {
//                        print("Fail")
//                    }
//                }) { (error) in
//                    print("Error retrieving values")
//                }
//            } else {
//                self.saveButton.setFATitleColor(color: UIColor.flatGray())
//                self.saveButtonLabel.text = "Unsaved"
//                let dictionaryData = [
//                    "autoID" : favoritesItem.key,
//                    "restaurantName" : self.userData.name,
//                    "restaurantID" : self.userData.restaurantID
//                ]
//                favoritesItem.childByAutoId().setValue(dictionaryData)
//                favoritesItemDictionary[self.userData.restaurantID] = self.userData
//                print("Added to Favorites")
//                Drop.down("Added \(self.userData.name) to Favorites!", state: .success)
//            }
//        }
                
//        isChecked = !isChecked
//        if !isChecked {
//            let user = Auth.auth().currentUser
//            if user != nil {
//                let usersRef = Database.database().reference().child("Users")
//                let currentUserRef = usersRef.child("\(user?.uid ?? "")")
//                let favoriteForThisUserRef = currentUserRef.child("favorites")
//                let dictionaryData = [
//                    "autoID" : favoriteForThisUserRef.key,
//                    "restaurantName" : userData.name,
//                    "restaurantID" : userData.restaurantID
//                ]
//                favoriteForThisUserRef.childByAutoId().setValue(dictionaryData)
//            }
//            favoritesItemDictionary[userData.restaurantID] = userData
//            print("Added to Favorites")
//            Drop.down("Added \(userData.name) to Favorites!", state: .success)
//            saveButton.setFATitleColor(color: UIColor.flatGray())
//        } else {
//            let user = Auth.auth().currentUser
//            if user != nil {
//                let usersRef = Database.database().reference().child("Users")
//                let currentUserRef = usersRef.child("\(user?.uid ?? "")")
//                let favoriteForThisUserRef = currentUserRef.child("favorites")
//                favoriteForThisUserRef.child(userData.restaurantID).removeValue { error, _ in
//                    if error != nil {
//                        print("error \(error)")
//                    } else {
//                        print("Removed from firebase too!")
//                    }
//                }
//            }
//            self.saveButton.setFATitleColor(color: UIColor.init(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0))
//            print("Removed from Favorites")
//            favoritesItemDictionary[userData.restaurantID] = nil
//            Drop.down("Removed \(userData.name) from Favorites!", state: .success)
//        }
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

    func setRelativeDistancesForEachRestaurant() {
        let userOriginsLocation = "\(userOriginalLocationParam[0]),\(userOriginalLocationParam[1])"
        let restaurantID = userData.restaurantID
        let destinationLatitude = userData.mapCoordinates[0]
        let destionationLongitude = userData.mapCoordinates[1]
        let parameters : [String: String] = [
            "origins" : userOriginsLocation,
            "destinations" : "\(destinationLatitude),\(destionationLongitude)",
            "mode" : "walking",
            "key": GOOGLE_MAP_DISTANCE_MATRIX_API_KEY]
        Alamofire.request(GOOGLE_MAP_DISTANCE_URL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Setting relative distance & duration")
                let result : JSON = JSON(response.result.value!)
                for currentElement in result["rows"][0]["elements"].arrayValue {
                    let status = currentElement["status"].string
                    if (status == "OK") {
                        let locationDistance = "\(currentElement["distance"]["text"].string ?? "")"
                        let locationDuration = "\(currentElement["duration"]["text"].string ?? "")"
                        print("\(locationDistance), \(locationDuration)")
                        self.userData.relativeDistanceFromUserCurrentLocation = locationDistance
                        self.userData.relativeDurationFromUserCurrentLocation = locationDuration
                        restaurantsData[restaurantID]?.updateRelativeDistancesAndDuration(newDistance: locationDistance, newDuration: locationDuration)
                    }
                }
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
}

extension MasterDetailViewController: UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {

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

