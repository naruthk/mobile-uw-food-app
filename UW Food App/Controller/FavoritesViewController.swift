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

class FavoritesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO:
        // 1. If the user has not logged in, then the Right button should display "Login". Vice versa.
        // 2. If the user has already logged in, then the Left button should be hidden.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func logoutButtonPressed(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//            Drop.down("You've successfuly logged out.", state: .success)
//            self.tabBarController?.selectedIndex = 0;   // Go back to Discover tab
//        }
//        catch {
//            print("Unable to logout")
//            Drop.down("Detecting network problem. Unable to logout.", state: .error)
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
