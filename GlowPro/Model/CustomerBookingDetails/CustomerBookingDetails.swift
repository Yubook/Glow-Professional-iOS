//
//  CustomerBookingDetails.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumCustomerDetails{
    case serviceCell
    case addressCell
    case galleryCell
    case reviewCell
    
    var cellId: String{
        switch self{
        case .serviceCell:
            return "serviceCell"
        case .addressCell:
            return "addressCell"
        case .galleryCell:
            return "gallaryCell"
        case .reviewCell :
            return "reviewCell"
        }
    }
    
    var cellHeight : CGFloat{
        switch self{
        case .serviceCell,.addressCell,.reviewCell:
            return UITableView.automaticDimension
        case .galleryCell:
            return 90.widthRatio
        }
    }
}

struct CustomerDetailsModel{
    var cellType : EnumCustomerDetails = .serviceCell
    var reviewType = ""
}

class CustomerDetailsData{
    var arrData : [CustomerDetailsModel] = []
    
    func prepareData(){
        var f0 = CustomerDetailsModel()
        f0.cellType  = .serviceCell
        self.arrData.append(f0)
        
        var f1 = CustomerDetailsModel()
        f1.cellType  = .addressCell
        self.arrData.append(f1)
        
        var f2 = CustomerDetailsModel()
        f2.cellType  = .galleryCell
        self.arrData.append(f2)
        
        
        var f3 = CustomerDetailsModel()
        f3.cellType  = .reviewCell
        f3.reviewType = "Service"
        self.arrData.append(f3)
        
        var f4 = CustomerDetailsModel()
        f4.cellType  = .reviewCell
        f4.reviewType = "Hygiene"
        self.arrData.append(f4)
        
        var f5 = CustomerDetailsModel()
        f5.cellType  = .reviewCell
        f5.reviewType = "Value"
        self.arrData.append(f5)
    }
}

class GetReview{
    var rating : String
    var msg : String
    var fromId : String
    var toId : String
    var fromUser : FromUsers?
    var toUser : ToUser?
    var arrImage : [ReviewImage] = []
    
    init(dict: NSDictionary) {
        rating = dict.getStringValue(key: "rating")
        msg = dict.getStringValue(key: "message")
        fromId = dict.getStringValue(key: "from_id")
        toId = dict.getStringValue(key: "to_id")
        if let imgData = dict["image"] as? [NSDictionary]{
            for data in imgData{
                let imgDict = ReviewImage(dict: data)
                self.arrImage.append(imgDict)
            }
        }
        if let userData = dict["from_id_user"] as? NSDictionary{
            self.fromUser = FromUsers(dict: userData)
        }
        if let driverData = dict["to_id_user"] as? NSDictionary{
            self.toUser = ToUser(dict: driverData)
        }
    }
}

class ReviewImage{
    var name : String
    var imgUrl : URL?{
        return URL(string: _storage+name)
    }
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "image")
    }
}

class FromUsers{
    let id : String
    let name : String
    let imageName : String
    var address : String
    
    var profileUrl : URL?{
        return URL(string: _storage+imageName)
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        address = dict.getStringValue(key: "address")
        imageName = dict.getStringValue(key: "image")
    }
}

class ToUser{
    let id : String
    let name : String
    let imageName : String
    
    var profileUrl : URL?{
        return URL(string: _storage+imageName)
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        imageName = dict.getStringValue(key: "image")
    }
}
