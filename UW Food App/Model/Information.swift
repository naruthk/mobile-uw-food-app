//
//  InformationSection.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/27/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

struct Information {
    
    var leftText: String!
    var rightText: String!
    
    init(label: String, information: String) {
        self.leftText = label
        self.rightText = information
    }
}
