//
//  SelectServices.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

class Services{
    let id : String
    var name : String
    var time : String
    var dictCategory : Category?
    var dictSubCategory : SubCategory?
    var isSelected = false
    var price : String = ""
    var isServiceAdded : Bool
    var editServiceId : String
    var slotTime : String
    var slotDate : Date?
    var serviceName : String
    
    var strDate : String{
        let stringDate = Date.localDateString(from: slotDate,format: "yyyy-MM-dd")
        return stringDate
    }
    var startChatTime : String{
        let subStr = slotTime.prefix(5)
        let time = subStr.prefix(2)
        var otherTime = String(time)
        if otherTime.last! == ":"{
            otherTime.removeLast()
            let strTime = Int(otherTime)
            let firstTime = strTime! - 1
            let end = subStr.suffix(3)
            return strDate + " " + "0\(firstTime)"+"\(end)"
        }else{
            let strTime = Int(otherTime)
            let firstTime = strTime! - 1
            let end = subStr.suffix(3)
            return strDate + " " + "\(firstTime)"+"\(end)"
        }
    }
    
    var chatEndTime : String{
        let subStr = slotTime.suffix(5)
        return strDate + " " + subStr
    }
    
    func getTimeAndDate() -> String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    
    var isServicesAdded : Bool{
        return isServiceAdded == true ? false : true
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        time = dict.getStringValue(key: "time")
        isServiceAdded = dict.getBooleanValue(key: "service_added")
        price = dict.getStringValue(key: "price")
        editServiceId = dict.getStringValue(key: "service_id")
        if let catDict = dict["category"] as? NSDictionary{
            let objData = Category(dict: catDict)
            self.dictCategory = objData
        }
        if let subCatDict = dict["subcategory"] as? NSDictionary{
            let objData = SubCategory(dict: subCatDict)
            self.dictSubCategory = objData
        }
        serviceName = dict.getStringValue(key: "service_name")
        slotTime = dict.getStringValue(key: "slot_time")
        slotDate = Date.dateFromAppServerFormat(from: dict.getStringValue(key: "slot_date"))
    }
}

class Category{
    let id : String
    var name : String
    var isActive : Bool
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        isActive = dict.getBooleanValue(key: "is_active")
    }
}

class SubCategory{
    let id : String
    var name : String
    var isActive : Bool
    var dictCatName : CatName?
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        isActive = dict.getBooleanValue(key: "is_active")
        
        if let catNameDict = dict["category_name"] as? NSDictionary{
            let objData = CatName(dict: catNameDict)
            self.dictCatName = objData
        }
    }
}

class CatName{
    let id : String
    var name : String
    var isActive : Bool
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        isActive = dict.getBooleanValue(key: "is_active")
    }
}

class SelectedServices{
    var selServiceId : String
    var selPrice : String
    init(dict: NSDictionary) {
        selServiceId = dict.getStringValue(key: "service_id")
        selPrice = dict.getStringValue(key: "price")
    }
}
