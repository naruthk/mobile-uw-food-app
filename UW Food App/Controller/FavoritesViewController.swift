//
//  FavoritesViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/29/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Firebase
import SwiftyDrop

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var restaurants = SharedInstance.sharedInstance
    var favorites = SharedInstance.sharedInstance
    var favoriteItemsArray = [String]()
    var reviewsItem : [Reviews] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reviewsItem.removeAll()    // Clear data first
        self.tableView.reloadData()
        retrieveFavorites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func retrieveFavorites() {
        self.favorites.favoritesItemDictionary.removeAll()
        self.favoriteItemsArray.removeAll()
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let ref = Database.database().reference().child("users/\(currentUser.uid)/favorites")
        ref.queryOrderedByKey()
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let id = dictionary["id"] as! String
                self.favorites.favoritesItemDictionary[id] = self.restaurants.restaurantsData[id]
                self.favoriteItemsArray.append(id)
                self.tableView.reloadData()
            }
        }) { (error) in print(error)}
        
        self.tableView.reloadData()
        self.tableView.reloadSections([0], with: .none)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteItemsArray.count == 0 {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        }
        return favoriteItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteItemCell") as! FavoritesTableViewCell
        guard let restaurant = restaurants.restaurantsData[favoriteItemsArray[indexPath.row]] else {
            return cell
        }
        cell.titleLabel.text = restaurant._title
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.rating.text = restaurant._average_rating
        cell.category.text = restaurant._category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let restaurant = restaurants.restaurantsData[favoriteItemsArray[indexPath.row]] else {
            return
        }
        retrieveReviews(restaurant)
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "MasterDetail") as! MasterDetailViewController
        vc.userData = restaurant
        vc.hoursItem = [
            Information(label: "Sun", information: restaurant._hours["sun"]!),
            Information(label: "Mon", information: restaurant._hours["mon"]!),
            Information(label: "Tues", information: restaurant._hours["tues"]!),
            Information(label: "Wed", information: restaurant._hours["wed"]!),
            Information(label: "Thurs", information: restaurant._hours["thurs"]!),
            Information(label: "Fri", information: restaurant._hours["fri"]!),
            Information(label: "Sat", information: restaurant._hours["sat"]!)
        ]
        vc.locationsItem = [
            Information(label: "Husky Card", information: "Yes"),
            Information(label: "Debit, Credit Card", information: "Yes (VISA, MasterCard)"),
            Information(label: "Cash", information: "Yes")
        ]
        vc.paymentsItem = [
            Information(label: "Husky Card", information: "Yes"),
            Information(label: "Debit, Credit Card", information: "Yes (VISA, MasterCard)"),
            Information(label: "Cash", information: "Yes")
        ]
        vc.reviewsItem = self.reviewsItem
        let navBarOnVC: UINavigationController = UINavigationController(rootViewController: vc)
        self.present(navBarOnVC, animated: true, completion: nil)
    }
    
    func retrieveReviews(_ userData: Restaurant) {
        let reviewsDB = Database.database().reference().child("reviews/\(userData._id)")
        reviewsDB.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.populateReviews(dictionary: dictionary)
            }
        })
    }
    
    // Populates navigation bar titles and today's operating hours
    func populateReviews(dictionary: [String: AnyObject]) {
        let message = dictionary["message"] as! String
        let rating = dictionary["rating"] as! String
        let name = dictionary["name"] as! String
        let timestamp = dictionary["timestamp"] as! Double
        let review = Reviews(name: name, rating: rating, message: message, timestamp: timestamp)
        self.reviewsItem.append(review)
    }

}

