//
//  PaymentHistroy.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

//class PaymentHistroy{
//    var expence : String
//    var arrOrders : [Orders] = []
//    
//    init(dict: NSDictionary) {
//        expence = dict.getStringValue(key: "totalExpense")
//        if let arrOrderDict = dict["order"] as? [NSDictionary]{
//            for dictOrder in arrOrderDict{
//                let orderDict = Orders(dict: dictOrder)
//                self.arrOrders.append(orderDict)
//            }
//        }
//    }
//}

class Orders{
    var amount : String
    var isOrderCompleted : Int
    var userDetail : UserDetails?
    var arrServices : [UserBookedService] = []
    var bookedSlot : Slots?
    
    init(dict: NSDictionary) {
        amount = dict.getStringValue(key: "amount")
        isOrderCompleted = dict.getIntValue(key: "is_order_complete")
        if let userDict = dict["user"] as? NSDictionary{
            self.userDetail = UserDetails(dict: userDict)
        }
        if let serviceDict = dict["service"] as? [NSDictionary]{
            for dictService in serviceDict{
                let objData = UserBookedService(dict: dictService)
                self.arrServices.append(objData)
            }
        }
        if let slotDict = dict["slot"] as? NSDictionary{
            self.bookedSlot = Slots(dict: slotDict)
        }
    }
}

class UserDetails{
    var name : String
    var imageName : String
    
    var imgUrl : URL?{
        return URL(string: _storage+imageName)
    }
    
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "name")
        imageName = dict.getStringValue(key: "profile")
    }
}

class UserBookedService{
    let id : String
    var name : String
    var slotTime : String
    var slotDate : Date?
    var dictCategory : Category?
    var dictSubCategory : SubCategory?
    
    var strDate : String{
        let strPrefix = Date.localDateString(from: slotDate, format: "MMM d, yyyy")
        return "\(strPrefix) @ "
    }
    
    init(dict: NSDictionary) {
        
        name = dict.getStringValue(key: "name")
        id = dict.getStringValue(key: "id")
        slotTime = dict.getStringValue(key: "slot_time")
        slotDate = Date.dateFromAppServerFormat(from: dict.getStringValue(key: "slot_date"))
        if let catDict = dict["category"] as? NSDictionary{
            let objData = Category(dict: catDict)
            self.dictCategory = objData
        }
        if let subCatDict = dict["subcategory"] as? NSDictionary{
            let objData = SubCategory(dict: subCatDict)
            self.dictSubCategory = objData
        }
    }
}

class Slots {
    var slotDate : Date?
    var slotTime : BookedTime?
    
    var strDate : String{
        let strPrefix = Date.localDateString(from: slotDate, format: "MMM d, yyyy")
        return "\(strPrefix) @ "
    }
    
    init(dict: NSDictionary) {
        slotDate = Date.dateFromAppServerFormat(from: dict.getStringValue(key: "date"))
        if let timeDict = dict["timing_slot"] as? NSDictionary{
            self.slotTime = BookedTime(dict: timeDict)
        }
    }
}

class BookedTime{
    var time : String
    
    init(dict: NSDictionary) {
        time = dict.getStringValue(key: "time")
    }
}
