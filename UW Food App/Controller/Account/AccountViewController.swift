//
//  AccountViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/29/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Firebase
import SwiftyDrop
import PopupDialog

class AccountViewController: UIViewController {

    var restaurants = SharedInstance.sharedInstance
    var favorites = SharedInstance.sharedInstance
    let user = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismiss(animated: false) {}
        self.navigationItem.setHidesBackButton(true, animated: false)
        retrieveUserFavoriteItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func retrieveUserFavoriteItems() {
        guard let currentUser = Auth.auth().currentUser else {
            self.favorites.favoritesItemDictionary.removeAll()
            return
        }
        let ref = Database.database().reference().child("users/\(currentUser.uid)/favorites")
        ref.queryOrderedByKey()
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let id = dictionary["id"] as! String
                self.favorites.favoritesItemDictionary[id] = self.restaurants.restaurantsData[id]
            }
        }) { (error) in print(error)}
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        let title = "Confirmation"
        let message = "Are you sure you want to sign out from this account: \(user?.email ?? "")?"
        let popup = PopupDialog(title: title, message: message)
        let cancelBtn = CancelButton(title: "Cancel") {}
        let closeBtn = DefaultButton(title: "Yes, log me out") {
            do {
                try Auth.auth().signOut()
                Drop.down("You've signed out.", state: .success)
                Auth.auth()

                // Clear
                self.favorites.favoritesItemDictionary.removeAll()

                guard (self.navigationController?.popToRootViewController(animated: true)) != nil
                    else {
                        print("No viewcontrollers to pop.")
                        return
                }
            } catch {
                print("Error logging out")
                Drop.down("An unknown error unoccurred", state: .error)
            }
        }
        popup.addButtons([cancelBtn, closeBtn])
        self.present(popup, animated: true, completion: nil)
    }

}
