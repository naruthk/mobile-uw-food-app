//
//  Food.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/24/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

class Food {
    
    var name : String
    var price : Double
    var category : String
    
    init(name: String, price: Double, category: String) {
        self.name = name
        self.price = price
        self.category = category
    }
    
}
