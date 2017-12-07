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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
 
                
            } else if user == Auth.auth().currentUser {
                
                self.favorites.favoritesItemDictionary.removeAll()
                
                let usersRef = Database.database().reference().child("Users")
                let currentUser = usersRef.child("\(user?.uid ?? "")")
                let favoritesItem = currentUser.child("favorites")
                favoritesItem.observe(.childAdded, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let id = dictionary["restaurantID"] as! String
                        if !self.favoriteItemsArray.contains(id) {
                            self.favoriteItemsArray.append(id)
                        }
                        self.tableView.reloadData()
                    }
                }) { (error) in
                    print("Error retrieving values")
                }
                
                for id in self.favorites.favoritesItemDictionary.keys {
                    self.favoriteItemsArray.append(id)
                }
                self.tableView.reloadData()
                self.tableView.reloadSections([0], with: .none)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        // TO-DO: IMPLEMENTATION NEEDED
        
    }
    
}

