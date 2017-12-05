//
//  MasterDetailViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/26/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import ChameleonFramework
import Cosmos
import Firebase
import Font_Awesome_Swift
import PopupDialog
import SwiftyDrop

struct Category {
    let name : String
    var items : [AnyObject]
}

class MasterDetailViewController: UIViewController {
    
    var restaurants = SharedInstance.sharedInstance
    var favorites = SharedInstance.sharedInstance
    var userData : Restaurant = Restaurant(value: "")
    var sections = [Category]()
    var hoursItem : [Information] = []
    var locationsItem : [Information] = []
    var paymentsItem : [Information] = []
    var reviewsItem : [Reviews] = []
    var ratingComment : String = ""
    var ratingValue : String = ""
    var ratingSum : Double = 0.0
    var ratingCounter : Int = 0
    var ratingTotal : Double = 0.0
    let iconSize : CGFloat  = 35
    
    @IBOutlet weak var ratingPanel: CosmosView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callButtonLabel: UILabel!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var restaurantHours: UILabel!
    @IBOutlet weak var restaurantRatingLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesNavigationBarHairline = true
        sections = [
            Category(name:"Hours", items: hoursItem as [AnyObject]),
            Category(name:"Location", items: locationsItem as [AnyObject]),
            Category(name:"Payment Services", items: paymentsItem as [AnyObject]),
            Category(name:"Reviews", items: reviewsItem as [AnyObject])
        ]
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.sections.remove(at: self.sections.count - 1)
            self.sections.append(Category(name:"Reviews", items: self.reviewsItem as [AnyObject]))
            self.tableView.reloadSections([self.sections.count-1], with: .none)
        }
        retrieveReviews()
        setTableViewFunctionalities()
        populateHeader()
        populateRating()
        populateButtons()
        setupRatingPopup()
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
        let name = dictionary["name"] as! String
        let timestamp = dictionary["timestamp"] as! Double
        let review = Reviews(name: name, rating: rating, message: message, timestamp: timestamp)
        self.reviewsItem.append(review)
    }
    
    func setTableViewFunctionalities() {
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.flatWhite()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func populateHeader() {
        self.title = userData._title
        let day = Calendar.current.component(.weekday, from: Date()) - 1
        let dayValues = ["sun", "mon", "tues", "wed", "thurs", "fri", "sat"]
        let category = String(userData._category).capitalized
        restaurantCategory.text = category
        if (userData._hours[dayValues[day]] != nil) {
            let hoursOfOperationToday = userData._hours[dayValues[day]]
            restaurantHours.text = hoursOfOperationToday
        }
    }
    
    func populateRating() {
        if userData._average_rating == "0.0" || userData._average_rating == "-" {
            restaurantRatingLabel.text = "Be the first to review."
            ratingPanel.rating = 0.0
        } else {
            let rating = Double(userData._average_rating)!
            ratingPanel.rating = rating
            ratingPanel.settings.updateOnTouch = false
            ratingPanel.settings.starMargin = 1
            ratingPanel.settings.fillMode = .precise
            let color : UIColor
            if (rating > 4) {
                color = UIColor.flatRed()
            } else if rating > 3 {
                color = UIColor.flatOrange()
            } else {
                color = UIColor.flatGray()
            }
            ratingPanel.settings.filledColor = color
            ratingPanel.settings.emptyBorderColor = color
            ratingPanel.settings.filledBorderColor = color
            restaurantRatingLabel.text = "\(rating) | Leave a Review"
        }
    }
    
    func populateButtons() {
        setFavoriteIcon()
        callButton.setFAIcon(icon: .FAPhone, iconSize: iconSize, forState: .normal)
        mapsButton.setFAIcon(icon: .FAMapMarker, iconSize: iconSize, forState: .normal)
        websiteButton.setFAIcon(icon: .FALink, iconSize: iconSize, forState: .normal)
        moreInfoButton.setFAIcon(icon: .FAInfoCircle, iconSize: iconSize, forState: .normal)
        
        guard let color = UIColor.flatGrayColorDark() else { return }
        saveButton.tintColor = color
        saveButton.setFATitleColor(color: color)
        callButton.tintColor = color
        mapsButton.tintColor = color
        websiteButton.tintColor = color
        moreInfoButton.tintColor = color
        
        let call = userData._contact_phone
        if !call.isEmpty && call != "-" {
            callButtonLabel.text = "\(call)"
            callButtonLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    func setFavoriteIcon() {
        guard let color = UIColor.flatGray() else { return }
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.saveButton.setFATitleColor(color: color)
                self.saveButton.setFAIcon(icon: .FAStarO, iconSize: self.iconSize, forState: .normal)
                self.saveButtonLabel.text = "Add"
            } else {
                print("Determining the right state of Favorite icon for this user")
                let usersRef = Database.database().reference().child("Users")
                let currentUser = usersRef.child("\(user?.uid ?? "")")
                let favoritesItem = currentUser.child("favorites")
                favoritesItem.observe(.childAdded, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let id = dictionary["restaurants_id"] as! String
                        if id == self.userData._id {
                            self.saveButton.setFATitleColor(color: UIColor.red)
                            self.saveButton.setFAIcon(icon: .FAStar, iconSize: self.iconSize, forState: .normal)
                            self.saveButtonLabel.text = "Added"
                        } else {
                            self.saveButton.setFATitleColor(color: color)
                            self.saveButton.setFAIcon(icon: .FAStarO, iconSize: self.iconSize, forState: .normal)
                            self.saveButtonLabel.text = "Add"
                        }
                    }
                }) { (error) in
                    print("Error retrieving values. Defaulting to original state.")
                }
                self.saveButton.setFATitleColor(color: color)
                self.saveButton.setFAIcon(icon: .FAStarO, iconSize: self.iconSize, forState: .normal)
                self.saveButtonLabel.text = "Add"
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let title = "Message"
                let message = "You must be signed in before you can save restaurants to Favorites."
                let popup = PopupDialog(title: title, message: message)
                let close = CancelButton(title: "Close") {}
                popup.addButton(close)
                self.present(popup, animated: true, completion: nil)
            } else if user == Auth.auth().currentUser {
                let usersRef = Database.database().reference().child("Users")
                let currentUser = usersRef.child("\(user?.uid ?? "")")
                let favoritesItem = currentUser.child("favorites")
                favoritesItem.observe(.childAdded, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let id = dictionary["restaurants_id"] as! String
                        if self.favorites.favoritesItemDictionary.keys.contains(id) {
                            self.saveButton.setFATitleColor(color: UIColor.flatGray())
                            self.saveButton.setFAIcon(icon: .FAStarO, iconSize: self.iconSize, forState: .normal)
                            self.saveButtonLabel.text = "Add"
                            self.favorites.favoritesItemDictionary.removeValue(forKey: self.userData._id)
                            
                            // TO-DO: REMOVE THE ITEM OUT OF FIREBASE
                            
                        } else {
                            self.saveButton.setFATitleColor(color: UIColor.flatGray())
                            self.saveButton.setFAIcon(icon: .FAStar, iconSize: self.iconSize, forState: .normal)
                            self.saveButtonLabel.text = "Added"
                            Drop.down("Added \(self.userData._title) to Favorites!", state: .success)
                            self.favorites.favoritesItemDictionary[self.userData._id] = self.userData
                            
                            // TO-DO: INSERT THE ITEM INTO FIREBASE
                            
                        }
                    }
                }) { (error) in
                    print("Error retrieving values. Defaulting to original state.")
                }
                
                if !self.favorites.favoritesItemDictionary.keys.contains(self.userData._id) {
                    self.favorites.favoritesItemDictionary[self.userData._id] = self.userData
                    Drop.down("Added \(self.userData._title) to Favorites!", state: .success)
                    self.saveButton.setFATitleColor(color: UIColor.flatGray())
                    self.saveButton.setFAIcon(icon: .FAStar, iconSize: self.iconSize, forState: .normal)
                    self.saveButtonLabel.text = "Added"
                } else {
                    self.favorites.favoritesItemDictionary.removeValue(forKey: self.userData._id)
                    Drop.down("Successfully removed \(self.userData._title) from Favorites!", state: .success)
                    self.saveButton.setFATitleColor(color: UIColor.flatGray())
                    self.saveButton.setFAIcon(icon: .FAStarO, iconSize: self.iconSize, forState: .normal)
                    self.saveButtonLabel.text = "Add"
                }
            }
        }
    }
    
    func setupRatingPopup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleRatingTap(_:)))
        ratingPanel.addGestureRecognizer(tap)
    }
    
    @objc func handleRatingTap(_ sender: UITapGestureRecognizer) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let title = "Message"
                let message = "You must be signed in before you can provide a review."
                let popup = PopupDialog(title: title, message: message)
                let close = CancelButton(title: "Close") {}
                popup.addButton(close)
                self.present(popup, animated: true, completion: nil)
            } else if user == Auth.auth().currentUser {
                let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)
                let popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
                let cancelBtn = CancelButton(title: "Cancel", height: 60) {}
                let ratedBtn = DefaultButton(title: "Rate", height: 60) {
                    Drop.down("Thanks for rating the \(self.userData._title)", state: .success)
                    self.ratingComment = ratingVC.returnData()[0]
                    self.ratingValue = ratingVC.returnData()[1]
                    guard let user = Auth.auth().currentUser else { return }
                    let reviewsDB = Database.database().reference().child("reviews/\(self.userData._id)")
                    let reviewDictionary : [String: Any] = [
                        "message": self.ratingComment, "name": user.displayName ?? "-" ,
                        "sender": user.email ?? "-", "rating": "\(self.ratingValue.prefix(3))",
                        "timestamp": NSDate().timeIntervalSince1970
                    ]
                    reviewsDB.childByAutoId().setValue(reviewDictionary)
                    
                    // Fetch total ratings for this particular restaurant
                    let ratingsDB = Database.database().reference().child("reviews/\(self.userData._id)")
                    ratingsDB.queryOrdered(byChild: "rating").observe(.childAdded, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let str = dictionary["rating"] as! String
                            let value = Double(str.prefix(3))!
                            self.ratingSum = self.ratingSum + value
                            self.ratingCounter += 1
                        }
                    })
                    
                    // Neat trick. Let the fetching above finishes first before updating our restaurants JSON
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.ratingTotal = self.ratingSum / Double(self.ratingCounter)
                        let restaurantDB = Database.database().reference().child("restaurants/\(self.userData._id)")
                        let ratingDictionary = ["average_rating": "\(String(self.ratingTotal).prefix(3))"]
                        restaurantDB.updateChildValues(ratingDictionary)
                        self.ratingTotal = 0.0
                    }
                }
                popup.addButtons([cancelBtn, ratedBtn])
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func moreActionPressed(_ sender: Any) {
        let item1 = "Check out this place called the \(userData._title). They got some great food."
        let item2 = "- from the UW Food App!"
        let activityVC : UIActivityViewController = UIActivityViewController(activityItems: [item1, item2], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func moreInfoButtonPressed(_ sender: Any) {
        if !userData._description.isEmpty && userData._description != "-" {
            let title = "\(userData._title)"
            let message = "\(userData._description)"
            let popup = PopupDialog(title: title, message: message)
            let close = CancelButton(title: "Close") {}
            popup.addButton(close)
            self.present(popup, animated: true, completion: nil)
        } else {
            Drop.down("More information not available.", state: .warning)
        }
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
            leaveAppAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in return }))
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
            leaveAppAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in return }))
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
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.sections[section].items
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.sections[section].name == "Reviews" {
            return 100
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.sections[section].name == "Reviews" {
            let footer = UITableViewCell()
            return footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.sections[section].name == "Reviews" {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sections[section].name == "Hours" {
            let header = UITableViewCell()
            header.backgroundColor = UIColor.white
            header.textLabel?.text = "Information"
            header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            return header
        }
        if self.sections[section].name == "Reviews" {
            let header = UITableViewCell()
            header.backgroundColor = UIColor.white
            header.textLabel?.text = "Reviews"
            header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = self.sections[indexPath.section].items
        let item = items[indexPath.row]
        
        if indexPath.section == sections.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell")! as! CommentsCell
            let reviewItem = item as! Reviews
            let rating = Double(reviewItem.rating)!
            let color : UIColor
            if (rating > 4) {
                color = UIColor.flatRed()
            } else if rating > 3 {
                color = UIColor.flatOrange()
            } else {
                color = UIColor.flatGray()
            }
            let timestamp = Double(reviewItem.timestamp)
            let date = Date(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-d"
            let strDate = dateFormatter.string(from: date)
            cell.name.text = reviewItem.name
            cell.name.adjustsFontSizeToFitWidth = true
            cell.date.text = strDate
            cell.message.text = reviewItem.message
            cell.stars.rating = Double(reviewItem.rating)!
            cell.stars.text = reviewItem.rating
            cell.stars.settings.updateOnTouch = false
            cell.stars.settings.starMargin = 1
            cell.stars.settings.fillMode = .precise
            cell.stars.settings.filledColor = color
            cell.stars.settings.emptyBorderColor = color
            cell.stars.settings.filledBorderColor = color
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
        let informationItem = item as! Information
        cell.textLabel?.text = informationItem.leftText
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = informationItem.rightText
        return cell
    }
    
}


