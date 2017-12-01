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
    
    var favoritesItemArray = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let user = Auth.auth().currentUser
        if user != nil {
            let usersRef = Database.database().reference().child("Users")
            let currentUser = usersRef.child("\(user?.uid ?? "")")
            let favoritesItem = currentUser.child("favorites")
            favoritesItem.observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let restaurantID = dictionary["restaurantID"] as! String
                    if !self.favoritesItemArray.contains(restaurantID) {
                        self.favoritesItemArray.append(restaurantID)
                    }
                    self.tableView.reloadData()
                }
            }) { (error) in
                print("Error retrieving values")
                Drop.down("Please check your Internet connection.", state: .error)
            }
        } else {
            for (key, value) in favoritesItemDictionary {
                if !self.favoritesItemArray.contains(key) {
                    self.favoritesItemArray.append(key)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesItemArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
        guard let restaurant = restaurantsData[favoritesItemArray[indexPath.row]] else {
            return cell
        }
        cell.textLabel?.text = restaurant.name
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = String(restaurant.category).capitalized
        return cell
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
