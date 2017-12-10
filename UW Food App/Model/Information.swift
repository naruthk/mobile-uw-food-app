//
//  InformationSection.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/27/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

struct Information {
    
    var label: String!
    var information: String!
    var id = ""
    
    init(label: String, information: String) {
        self.label = label
        self.information = information
    }
    
    init(id:String, label: String, information: String) {
        self.id = id
        self.label = label
        self.information = information
    }
    
}
