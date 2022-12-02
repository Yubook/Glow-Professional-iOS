//
//  Reviews.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

class Reviews{
    var fromId : String
    var toId : String
    var rating : String
    var message : String
    var users : UsersReview?
    var drivers : DriversData?
    var arrimgList : [ImageList] = []
    
    init(dict: NSDictionary) {
        fromId = dict.getStringValue(key: "from_id")
        toId = dict.getStringValue(key: "to_id")
        rating = dict.getStringValue(key: "rating")
        message = dict.getStringValue(key: "message")
        if let userData = dict["from_id_user"] as? NSDictionary{
            self.users = UsersReview(dict: userData)
        }
        if let userData = dict["to_id_user"] as? NSDictionary{
            self.drivers = DriversData(dict: userData)
        }
        if let imgData = dict["image"] as? [NSDictionary]{
            if toId == _user.id{
                for imgs in imgData{
                    let dictData = ImageList(dict: imgs)
                    self.arrimgList.append(dictData)
                }
            }
        }
    }
}

class ImageList{
    var imgName : String
    var imgUrl : URL?{
        return URL(string: _storage+imgName)
    }
    
    init(dict: NSDictionary) {
        imgName = dict.getStringValue(key: "image")
    }
}

class UsersReview{
    var name : String
    var imgName : String
    
    var profileUrl : URL?{
        return URL(string: _storage+imgName)
    }
    
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "name")
        imgName = dict.getStringValue(key: "image")
    }
}

class DriversData{
    var id : String
    
    init(dict : NSDictionary) {
        id = dict.getStringValue(key: "id")
    }
}

