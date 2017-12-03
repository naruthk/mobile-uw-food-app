//
//  InformationSection.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/27/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

struct InformationSection {
    
    var type: String!
    var dataTitles: [String]!
    var dataDetails: [String]!
    var expanded: Bool!
    
    init(type: String, dataTitles: [String], dataDetails: [String], expanded: Bool) {
        self.type = type
        self.dataTitles = dataTitles
        self.dataDetails = dataDetails
        self.expanded = expanded
    }
}
