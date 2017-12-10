//
//  ResturantSettingsViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 12/9/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Firebase

class RestuarantSettingsViewController: UITableViewController {
    
    
    var restaurants = SharedInstance.sharedInstance
    
    var sections:[Restaurant.InformationCategory] = [Restaurant.InformationCategory(name: "", items: [])]
    
    var restuarantId:String = "" {
        didSet {
            sections = restuarant.toInformationCategoryArray()
            tableView.reloadData()
        }
    }
    var restuarant:Restaurant! {
        get {
            return restaurants.restaurantsData[restuarantId]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension RestuarantSettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.sections[section].items
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.sections[section].name == "Reviews" {
            return 100
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = self.sections[indexPath.section].items
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldTableViewCell
        let informationItem = item as! Information
        cell.label.text = informationItem.leftText
        cell.textField.placeholder = informationItem.rightText
        return cell
    }
    
}



