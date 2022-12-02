//
//  BookingDetail.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/16/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumBookingDetails{
    case previousCell
    case currentCell
    case featureCell
    
    init(idx : Int) {
        if idx == 0{
            self = .previousCell
        }else if idx == 1{
            self = .currentCell
        }else{
            self = .featureCell
        }
    }
}

class BookingList{
    var arrPreviousBooked :[PreviousBooking] = []
    var arrFeatureBooked : [PreviousBooking] = []
    var arrCurrentBooked : [PreviousBooking] = []
    
    init(dict: NSDictionary) {
        if let previousDict = dict["previous"] as? NSDictionary{
            if let previousData = previousDict["data"] as? [NSDictionary]{
                for data in previousData{
                    let dictData = PreviousBooking(dict: data)
                    self.arrPreviousBooked.append(dictData)
                }
            }
        }
        if let nextDict = dict["next"] as? NSDictionary{
            if let nextData = nextDict["data"] as? [NSDictionary]{
                for data in nextData{
                    let dictData = PreviousBooking(dict: data)
                    self.arrFeatureBooked.append(dictData)
                }
            }
        }
        if let currentDict = dict["today"] as? NSDictionary{
            if let currData = currentDict["data"] as? [NSDictionary]{
                for data in currData{
                    let dictData = PreviousBooking(dict: data)
                    self.arrCurrentBooked.append(dictData)
                }
            }
        }
    }
}

class PreviousBooking{
    var orderId : String
    var totalPay : String
    var isOrderCompleted : Int
    var users : UsersData?
    var arrServices : [BookedServices] = []
    var slots : BookedSlots?
    var arrUserReview : [NewReviews] = []
    var lat : String
    var long : String
    var address : String
    var arrReviewImgs : [NewReviewImages] = []
    var chat : Bool
    var chatId : String
    
    init(dict: NSDictionary) {
        orderId = dict.getStringValue(key: "id")
        totalPay = dict.getStringValue(key: "amount")
        isOrderCompleted = dict.getIntValue(key: "is_order_complete")
        address = dict.getStringValue(key: "address")
        if let userData = dict["user"] as? NSDictionary{
            self.users = UsersData(dict: userData)
        }
        if let serviceData = dict["service"] as? [NSDictionary]{
            for dictService in serviceData{
                let objData = BookedServices(dict: dictService)
                self.arrServices.append(objData)
            }
        }
        if let slotsData = dict["slot"] as? NSDictionary{
            self.slots = BookedSlots(dict: slotsData)
        }
        if let reviewData = dict["review"] as? [NSDictionary]{
            for dictData in reviewData{
                let objReview = NewReviews(dict: dictData)
                self.arrUserReview.append(objReview)
            }
        }
        if let arrImgs = dict["review_images"] as? [NSDictionary]{
            for dictImg in arrImgs{
                let objData = NewReviewImages(dict: dictImg)
                self.arrReviewImgs.append(objData)
            }
        }
        lat = dict.getStringValue(key: "latitude")
        long = dict.getStringValue(key: "longitude")
        chat = dict.getBooleanValue(key:  "chat")
        chatId = dict.getStringValue(key: "chat_group_id")
    }
}

class UsersData{
    var id : String
    var name : String
    var imgName : String
    var email : String
    var phone : String
    var address : String
    var lat : String
    var long : String
    var latestLat : String
    var latestLong : String
    var profileUrl : URL?{
        return URL(string: _storage+imgName)
    }
    
    init(dict : NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
        imgName = dict.getStringValue(key: "profile")
        email = dict.getStringValue(key: "email")
        phone = dict.getStringValue(key: "mobile")
        address = dict.getStringValue(key: "address_line_1")
        lat = dict.getStringValue(key: "latitude")
        long = dict.getStringValue(key: "longitude")
        latestLat = dict.getStringValue(key: "latest_latitude")
        latestLong = dict.getStringValue(key: "latest_longitude")
    }
}

class BookedServices{
    let id : String
    var name : String
    var slotTime : String
    var slotDate : Date?
    var dictCategory : Category?
    var dictSubCategory : SubCategory?
    
    var strDate : String{
        let strPrefix = Date.localDateString(from: slotDate, format: "EEEE, MMM d, yyyy")
        return "\(strPrefix) @ "
    }
    
    var strRevenueDate : String{
        let strDate = Date.localDateString(from: slotDate, format: "d MMM, yyyy")
        return "\(strDate) "
    }

    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "service_name")
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

class BookedSlots{
    var bookedDate : Date?
    var timeSlots : TimeSlots?
    var strDate : String{
        let strPrefix = Date.localDateString(from: bookedDate, format: "EEEE, MMM d, yyyy")
        return "\(strPrefix) @ "
    }
    
    var strSlotDate : String{
        let strSlotDate = Date.localDateString(from: bookedDate)
        return strSlotDate
    }
    init(dict: NSDictionary) {
        bookedDate = Date.dateFromAppServerFormat(from: dict.getStringValue(key: "date"))
        if let time = dict["timing_slot"] as? NSDictionary{
            self.timeSlots = TimeSlots(dict: time)
        }
    }
}

class TimeSlots{
    var time : String
    
    init(dict: NSDictionary) {
        time = dict.getStringValue(key: "time")
    }
}


class NewReviews{
    var id : String
    var orderId : String
    var userId : String
    var service : Int
    var hygine : Int
    var value : Int
    var arrReviewImg : [NewReviewImages] = []
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        orderId = dict.getStringValue(key: "order_id")
        userId = dict.getStringValue(key: "user_id")
        service = dict.getIntValue(key: "service")
        hygine = dict.getIntValue(key: "hygiene")
        value = dict.getIntValue(key: "value")
        if let arrImgs = dict["review_images"] as? [NSDictionary]{
            for imgs in arrImgs{
                let objData = NewReviewImages(dict: imgs)
                self.arrReviewImg.append(objData)
            }
        }
    }
}

class NewReviewImages{
    var reviewId : String
    var img : String
    
    var imgUrl : URL?{
        return URL(string: _storage+img)
    }
    
    init(dict: NSDictionary) {
        reviewId = dict.getStringValue(key: "id")
        img = dict.getStringValue(key: "image")
    }
}
