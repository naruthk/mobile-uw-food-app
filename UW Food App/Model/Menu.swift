//
//  Menu.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/24/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

class Menu {
    
    var restaurantID : String
    var food : [Food]
    
    init(restaurantID: String, food: [Food]) {
        self.restaurantID = restaurantID
        self.food = food
    }
    
}
