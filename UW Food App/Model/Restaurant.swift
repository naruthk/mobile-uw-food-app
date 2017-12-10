//
//  Restaurant.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/23/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import Foundation

class Restaurant: NSObject, NSCoding {
    
    struct Keys {
        static let id = "id"
        static let title = "title"
        static let description = "description"
        static let building = "building"
        static let address = "address"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let category = "category"
        static let average_rating = "average_rating"
        static let hours = "hours"
        static let contact_name = "contact_name"
        static let contact_email = "contact_email"
        static let contact_phone = "contact_phone"
        static let contact_website = "contact_website"
        static let distance = "distance"
        static let duration = "duration"
    }
    
    
    
    var _id : String = "-"
    var _title : String = "-"
    var _description : String = "-"
    var _building : String = "-"
    var _address : String = "-"
    var _latitude : String = "-"
    var _longitude : String = "-"
    var _category : String = "-"
    var _average_rating : String = "-"
    var _hours : [String:String] = ["-":"-"]
    
    var _sunday_hour:String! { get {return _hours["sun"]} set { _hours["sun"] = newValue } }
    var _monday_hour:String! { get {return _hours["mon"]} set { _hours["mon"] = newValue } }
    var _tuesday_hour:String! { get {return _hours["tues"]} set { _hours["tues"] = newValue } }
    var _wednesday_hour:String! { get {return _hours["wed"]} set { _hours["wed"] = newValue } }
    var _thursday_hour:String! { get {return _hours["thurs"]} set { _hours["thurs"] = newValue } }
    var _friday_hour:String! { get {return _hours["fri"]} set { _hours["fri"] = newValue } }
    var _saturday_hour:String! { get {return _hours["sat"]} set { _hours["sat"] = newValue } }
    
    var _contact_name : String = "-"
    var _contact_email : String = "-"
    var _contact_phone : String = "-"
    var _contact_website : String = "-"
    var _distance : String = ""
    var _duration : String = ""
    
    init(id : String, title: String, description: String, building: String, address: String, latitude: String,
         longitude: String, category: String, average_rating: String, hours: [String:String], contact_name: String,
         contact_email: String, contact_phone: String, contact_website: String, distance : String, duration : String) {
        self._id = id
        self._title = title
        self._description = description
        self._building = building
        self._address = address
        self._latitude = latitude
        self._longitude = longitude
        self._category = category
        self._average_rating = average_rating
        self._hours = hours
        self._contact_name = contact_name
        self._contact_email = contact_email
        self._contact_phone = contact_phone
        self._contact_website = contact_website
        self._distance = distance
        self._duration = duration
    }
    
    init(value: String) {
        self._id = value
        self._title = value
        self._description = value
        self._building = value
        self._address = value
        self._latitude = value
        self._longitude = value
        self._category = value
        self._average_rating = value
        self._hours = [value:value]
        self._contact_name = value
        self._contact_email = value
        self._contact_phone = value
        self._contact_website = value
        self._distance = value
        self._duration = value
    }
    
    required init(coder decoder: NSCoder) {
        if let id = decoder.decodeObject(forKey: Keys.id) as? String {
            _id = id
        }
        if let title = decoder.decodeObject(forKey: Keys.title) as? String {
            _title = title
        }
        if let description = decoder.decodeObject(forKey: Keys.description) as? String {
            _description = description
        }
        if let building = decoder.decodeObject(forKey: Keys.building) as? String {
            _building = building
        }
        if let address = decoder.decodeObject(forKey: Keys.address) as? String {
            _address = address
        }
        if let latitude = decoder.decodeObject(forKey: Keys.latitude) as? String {
            _latitude = latitude
        }
        if let longitude = decoder.decodeObject(forKey: Keys.longitude) as? String {
            _longitude = longitude
        }
        if let category = decoder.decodeObject(forKey: Keys.category) as? String {
            _category = category
        }
        if let averageRating = decoder.decodeObject(forKey: Keys.average_rating) as? String {
            _average_rating = averageRating
        }
        if let hours = decoder.decodeObject(forKey: Keys.hours) as? [String:String] {
            _hours = hours
        }
        if let contactName = decoder.decodeObject(forKey: Keys.contact_name) as? String {
            _contact_name = contactName
        }
        if let contactPhone = decoder.decodeObject(forKey: Keys.contact_phone) as? String {
            _contact_phone = contactPhone
        }
        if let contactEmail = decoder.decodeObject(forKey: Keys.contact_email) as? String {
            _contact_email = contactEmail
        }
        if let contactWebsite = decoder.decodeObject(forKey: Keys.contact_website) as? String {
            _contact_website = contactWebsite
        }
        if let distance = decoder.decodeObject(forKey: Keys.distance) as? String {
            _distance = distance
        }
        if let duration = decoder.decodeObject(forKey: Keys.duration) as? String {
            _duration = duration
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(_id, forKey: Keys.id)
        coder.encode(_title, forKey: Keys.title)
        coder.encode(_description, forKey: Keys.description)
        coder.encode(_building, forKey: Keys.building)
        coder.encode(_address, forKey: Keys.address)
        coder.encode(_latitude, forKey: Keys.latitude)
        coder.encode(_longitude, forKey: Keys.longitude)
        coder.encode(_category, forKey: Keys.category)
        coder.encode(_average_rating, forKey: Keys.average_rating)
        coder.encode(_hours, forKey: Keys.hours)
        coder.encode(_contact_name, forKey: Keys.contact_name)
        coder.encode(_contact_email, forKey: Keys.contact_email)
        coder.encode(_contact_phone, forKey: Keys.contact_phone)
        coder.encode(_contact_website, forKey: Keys.contact_website)
        coder.encode(_distance, forKey: Keys.distance)
        coder.encode(_duration, forKey: Keys.duration)
    }
    
    func updateDistance(distance: String) {
        self._distance = distance
    }
    
    func updateDuration(duration: String) {
        self._duration = duration
    }
    
    func updateRating(rating: String) {
        self._average_rating = rating
    }
    
    func toString() -> String {
        return "Restaurant: \(_id) \(_title) \(_description) \(_building) \(_address) \(_latitude) \(_longitude) \(_category) \(_average_rating) \(_hours) \(_contact_name) \(_contact_email) \(_contact_phone) \(_contact_website) | Distance: \(_distance), Duration: \(_duration)"
    }
    
    
    
    struct InformationCategory {
        let name : String
        var items : [AnyObject]
    }
    
    func toInformationCategoryArray() -> [InformationCategory]{
        let hoursItem = [
            Information(id: "_sunday_hour", label: "Sunday", information: self._hours["sun"]!),
            Information(id: "_monday_hour", label: "Monday", information: self._hours["mon"]!),
            Information(id: "_tuesday_hour", label: "Tuesday", information: self._hours["tues"]!),
            Information(id: "_wednesday_hour", label: "Wednesday", information: self._hours["wed"]!),
            Information(id: "_thursday_hour", label: "Thursday", information: self._hours["thurs"]!),
            Information(id: "_friday_hour", label: "Friday", information: self._hours["fri"]!),
            Information(id: "_saturday_hour", label: "Saturday", information: self._hours["sat"]!)
        ]
        let basicItem = [
            Information(id: "_category", label: "Category", information: self._category),
            Information(id: "_contact_phone", label: "Phone Number", information: self._contact_phone),
            ]
        let paymentsItem = [
            Information(label: "Husky Card", information: "Yes"),
            Information(label: "Debit, Credit Card", information: "Yes (VISA, MasterCard)"),
            Information(label: "Cash", information: "Yes")
        ]
        
        return [
            InformationCategory(name:"Hours", items: hoursItem as [AnyObject]),
            InformationCategory(name:"Basic", items: basicItem as [AnyObject]),
            InformationCategory(name:"Payment Services", items: paymentsItem as [AnyObject])
        ]
    }
    
    func updateFrom(information:Information) {
        print("\(information.label) : \(information.information)")
        if information.id != "" {
            switch information.id {
            case "_sunday_hour":
                _sunday_hour = information.information
            case "_monday_hour":
                _monday_hour = information.information
            case "_tuesday_hour":
                _tuesday_hour = information.information
            case "_wednesday_hour":
                _wednesday_hour = information.information
            case "_thursday_hour":
                _thursday_hour = information.information
            case "_friday_hour":
                _friday_hour = information.information
            case "_category":
                _category = information.information
            case "_contact_phone":
                _contact_phone = information.information
            default:
                print("\(information.id) not found")
            }
        }
        
    }
    
    var structuredObjectForFireBase: [String:Any] {
        get {
            return [
                "id": self._id,
                "title": self._title,
                "description": self._description,
                "address": self._address,
                "building": self._building,
                "category": self._category,
                "average_rating": self._average_rating,
                "latitude": self._latitude,
                "longitude": self._longitude,
                "contactInformation": [
                    "name": self._contact_name,
                    "email" : self._contact_email,
                    "phone" : self._contact_phone,
                    "website" : self._contact_website
                ],
                "hours": self._hours,
            ]
        }
    }
}

