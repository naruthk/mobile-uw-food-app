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

class MasterDetailViewController: UIViewController {

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
    
    @IBOutlet weak var topHeroView: UIView!
    @IBOutlet weak var restaurantTitleLabel: UILabel!
    @IBOutlet weak var restaurantShortInformationLabel: UILabel!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHeroView.backgroundColor = UIColor.randomFlat()
        addToFavoriteButton.setFAIcon(icon: .FABookmarkO, iconSize: 25, forState: .normal)
        
        populateHeader()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func backToDiscoveryButton(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func addToFavoriteButton(_ sender: Any) {
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
