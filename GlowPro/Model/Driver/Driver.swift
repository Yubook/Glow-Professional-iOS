//
//  Driver.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/7/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import CoreData

class Driver : NSManagedObject, ParentManagedObject{
    
    @NSManaged var id : String
    @NSManaged var role : String
    @NSManaged var name : String
    @NSManaged var email : String
    @NSManaged var mobile : String
    @NSManaged var image : String
    @NSManaged var address : String
    @NSManaged var latitude : String
    @NSManaged var longitude : String
    @NSManaged var vanNumber : String
    @NSManaged var gender : String
    @NSManaged var isServiceAdded : Bool
    @NSManaged var isAvailblity : Bool
    @NSManaged var minRadius : String
    @NSManaged var maxRadius : String
    
    var profileUrl : URL?{
        return URL(string: _storage + image)
    }
    
    func initWith(dict : NSDictionary){
        id = dict.getStringValue(key: "id")
        role = dict.getStringValue(key: "role_id")
        name = dict.getStringValue(key: "name")
        email = dict.getStringValue(key: "email")
        mobile = dict.getStringValue(key: "mobile")
        image = dict.getStringValue(key: "profile")
        address = dict.getStringValue(key: "address_line_1")
        latitude = dict.getStringValue(key: "latitude")
        longitude = dict.getStringValue(key: "longitude")
        vanNumber = dict.getStringValue(key: "van_number")
        gender = dict.getStringValue(key: "gender")
        isServiceAdded = dict.getBooleanValue(key: "is_service_added")
        isAvailblity = dict.getBooleanValue(key: "is_availability")
        minRadius = dict.getStringValue(key: "min_radius")
        maxRadius = dict.getStringValue(key: "max_radius")
    }
}
