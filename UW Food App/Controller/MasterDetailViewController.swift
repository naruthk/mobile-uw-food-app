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
import Firebase

var favoritesItemDictionary = [String:Restaurant]()

class MasterDetailViewController: UIViewController {
    
    var restaurants = SharedInstance.sharedInstance
    var userData : Restaurant = Restaurant(value: "")
    var informationSections : [InformationSection] = []
    let colorForOverall : UIColor = UIColor.flatPurpleColorDark()
    let reviewsPanelView = UIView()
    var reviewsSection = [Reviews]()
    
    @IBOutlet weak var ratingPanel: CosmosView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callButtonLabel: UILabel!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var restaurantHours: UILabel!
    @IBOutlet weak var restaurantRatingLabel: UILabel!
    @IBOutlet weak var infoButtonLabel: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesNavigationBarHairline = true
        
        let reviews = InformationSection(type: "Reviews", dataTitles: ["Anthony"], dataDetails: ["Quite unexpected!"], expanded: true)
        informationSections.append(reviews)
        
        
        retrieveReviews()
        setTableViewFunctionalities()
        populateHeader()
        populateRating()
        populateButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func retrieveReviews() {
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
        let sender = dictionary["sender"] as! String
        let timestamp = dictionary["timestamp"] as! Double
        let reviewData = Reviews(sender: sender, rating: rating, message: message, timestamp: timestamp)
        reviewsSection.append(reviewData)
    }
    
    func setTableViewFunctionalities() {
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.flatWhite()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func populateHeader() {
        self.title = userData._title
        let todayDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: todayDate) - 1
        let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
        let category = String(userData._category).capitalized
        restaurantCategory.text = category
        if (userData._hours[dayValues[day]] != nil) {
            let hoursOfOperationToday = userData._hours[dayValues[day]]
            restaurantHours.text = hoursOfOperationToday
        }
    }
    
    func populateRating() {
        if userData._average_rating == "-" {
            restaurantRatingLabel.text = "No ratings"
        } else {
            let rating = userData._average_rating
            ratingPanel.rating = Double(rating)!
            ratingPanel.settings.updateOnTouch = false
            ratingPanel.settings.starMargin = 2
            ratingPanel.settings.filledColor = UIColor.flatGray()
            ratingPanel.settings.emptyBorderColor = UIColor.flatGray()
            ratingPanel.settings.filledBorderColor = UIColor.flatGray()
            restaurantRatingLabel.text = rating
        }
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
                    if restaurantID == self.userData._id {
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
            if favoritesItemDictionary.keys.contains(userData._id) {
                self.saveButton.setFATitleColor(color: UIColor.flatGray())
            } else {
                self.saveButton.setFATitleColor(color: UIColor.init(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0))
            }
        }
        infoButtonLabel.setFAIcon(icon: .FAInfoCircle, iconSize: 25)
        saveButton.setFAIcon(icon: .FAStarO, iconSize: 30, forState: .normal)
        callButton.setFAIcon(icon: .FAPhone, iconSize: 30, forState: .normal)
        mapsButton.setFAIcon(icon: .FAMap, iconSize: 30, forState: .normal)
        websiteButton.setFAIcon(icon: .FALink, iconSize: 30, forState: .normal)
        
        infoButtonLabel.tintColor = UIColor.flatGray()
        saveButton.tintColor = UIColor.flatGray()
        callButton.tintColor = UIColor.flatGray()
        mapsButton.tintColor = UIColor.flatGray()
        websiteButton.tintColor = UIColor.flatGray()
        
        let call = userData._contact_phone
        if !call.isEmpty && call != "-" {
            callButtonLabel.text = "\(call)"
        }
    }
    
    @IBAction func revealInfoButtonPressed(_ sender: Any) {
        if !userData._description.isEmpty && userData._description != "-" {
            let infoAlert = UIAlertController(title: userData._title, message: userData._description, preferredStyle: UIAlertControllerStyle.alert)
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
        let call = userData._contact_phone
        if !call.isEmpty && call != "-" {
            let url = URL(string: "tel://\(call)")
            UIApplication.shared.open(url!)
        } else {
            Drop.down("Unable to retrieve phone number.", state: .warning)
        }
    }
    
    @IBAction func openMap(_ sender: Any) {
        let errorMessage = "Unable to retrieve map data"
        let restaurantID = userData._id
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
        let website = userData._contact_website
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
}

extension MasterDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return informationSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return reviewsSection.count
        }
        return informationSections[section].dataDetails.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 100
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 {
            let footer = UITableViewCell()
            return footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 {
            let reviewHeader = UITableViewCell()
            reviewHeader.backgroundColor = UIColor.white
            reviewHeader.textLabel?.text = "Reviews"
            reviewHeader.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            return reviewHeader
        }
        let header = UITableViewCell()
        header.textLabel?.text = informationSections[section].type
        header.textLabel?.textColor = UIColor(hexString: "#333333")
        header.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        header.backgroundColor = UIColor(hexString: "#f7f7f7")
        header.detailTextLabel?.text = "\(informationSections[section].dataDetails.count) reviews"
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell")! as! CommentsCell
//            let review = reviewsSection[indexPath.section]
            let review = reviewsSection[0]
            let date = Date(timeIntervalSince1970: review.timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-d"
            let strDate = dateFormatter.string(from: date)
            cell.name.text = review.sender
            cell.name.adjustsFontSizeToFitWidth = true
            cell.date.text = strDate
            cell.message.text = review.message
            cell.stars.rating = Double(review.rating)!
            cell.stars.text = review.rating
            cell.stars.settings.updateOnTouch = false
            cell.stars.settings.starMargin = 2
            cell.stars.settings.filledColor = UIColor.flatGray()
            cell.stars.settings.emptyBorderColor = UIColor.flatGray()
            cell.stars.settings.filledBorderColor = UIColor.flatGray()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
        cell.textLabel?.text = informationSections[indexPath.section].dataTitles[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = informationSections[indexPath.section].dataDetails[indexPath.row]
        return cell
    }
    
}


