//
//  DriverUserLocations.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/22/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

class DriverLocation{
    var latitude : String
    var longitude : String
    var users : User?
    
    init(dict: NSDictionary) {
        latitude = dict.getStringValue(key: "latitude")
        longitude = dict.getStringValue(key: "longitude")
        
        if let userData = dict["user"] as? NSDictionary{
            self.users = User(dict: userData)
        }
    }
}

class User{
    var id : String
    var name : String
    var email : String
    var add : String
    var lat : String
    var long : String
    var latest_lat : String
    var latest_long : String
    var imageName : String
    
    var profileUrl : URL?{
        return URL(string: imageName)
    }
    
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        email = dict.getStringValue(key: "email")
        add = dict.getStringValue(key: "address")
        lat = dict.getStringValue(key: "latitude")
        long = dict.getStringValue(key: "longitude")
        latest_lat = dict.getStringValue(key: "latest_latitude")
        latest_long = dict.getStringValue(key: "latest_longitude")
        imageName = dict.getStringValue(key: "image")
    }
}

