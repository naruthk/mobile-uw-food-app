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
    var permissions = SharedInstance.sharedInstance
    let user = Auth.auth().currentUser
    
    private lazy var favoritesViewController: FavoritesViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Favorites", bundle: nil)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var restuarantSettingsViewController: RestuarantSettingsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Account", bundle: Bundle.main)
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "RestuarantSettingsViewController") as! RestuarantSettingsViewController
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismiss(animated: false) {}
        self.navigationItem.setHidesBackButton(true, animated: false)
        retrieveUserFavoriteItems()
        retrieveAccount()
        setAccountView()
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
    
    func retrieveAccount() {
        guard let currentUser = Auth.auth().currentUser else {
            self.permissions.accountPermissions.removeAll()
            return
        }
        let ref = Database.database().reference().child("users/\(currentUser.uid)/permissions")
        ref.queryOrderedByKey()
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]
            {
                if let id = dictionary["restuarantId"] as? String,
                    let value = dictionary["value"] as? String {
                    self.permissions.accountPermissions[id] = value
                    self.setAccountView()
                }
                
            }
        }) { (error) in print(error)}
    }
    
    func setAccountView() {
        if let firstObject = self.permissions.accountPermissions.first
            , firstObject.value.contains("w"),
            let restuarentId = self.permissions.accountPermissions.first?.key {
            navigationItem.title = restaurants.restaurantsData[restuarentId]?._title
            restuarantSettingsViewController.restuarantId = restuarentId
            remove(asChildViewController: favoritesViewController)
            add(asChildViewController: restuarantSettingsViewController)
            
        } else {
            navigationItem.title = "My Food"
            tabBarItem.title = "My Food"
            remove(asChildViewController: restuarantSettingsViewController)
            add(asChildViewController: favoritesViewController)
        }
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
                self.permissions.accountPermissions.removeAll()
                
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
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
}

//extension AccountViewController: UITabBarControllerDelegate {
//
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if (self.navigationController == viewController) {
//            return false
//        }
//        return true
//    }
//
//}

