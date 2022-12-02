//
//  Insgiht.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/23/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

class Insight{
    var arrMonthSix : [Month6And3AndYear] = []
    var arrMonthThree : [Month6And3AndYear] = []
    var arrMonthOne : [Month1] = []
    var arrWeekOne : [Week1] = []
    var arrYearOne : [Month6And3AndYear] = []
    
    init(dict: NSDictionary) {
        if let sixMonthDict = dict["somemonths"] as? [NSDictionary]{
            for dict in sixMonthDict{
                let sixMonthData = Month6And3AndYear(dict: dict)
                self.arrMonthSix.append(sixMonthData)
            }
        }
        
        if let threeMonthDict = dict["somemonths"] as? [NSDictionary]{
            for dict in threeMonthDict{
                let threeMonthData = Month6And3AndYear(dict: dict)
                self.arrMonthThree.append(threeMonthData)
            }
        }
        
        if let oneMonthDict = dict["1month"] as? [NSDictionary]{
            for dict in oneMonthDict{
                let oneMonthData = Month1(dict: dict)
                self.arrMonthOne.append(oneMonthData)
            }
        }
        
        if let oneWeekDict = dict["1Week"] as? [NSDictionary]{
            for dict in oneWeekDict{
                let oneWeekData = Week1(dict: dict)
                self.arrWeekOne.append(oneWeekData)
            }
        }
        
        if let oneYearDict = dict["yearly"] as? [NSDictionary]{
            for dict in oneYearDict{
                let oneYearData = Month6And3AndYear(dict: dict)
                self.arrYearOne.append(oneYearData)
            }
        }
    }
}

class Month6And3AndYear{
    var revenue : String
    var month : Date?
    var year : Date?
    
    var strMonth : String{
        let getMonth = Date.localDateString(from: month, format: "MMM")
        
        return getMonth
    }
    var strYear : String{
        let getYear =  Date.localDateString(from: year, format: "yyyy")
        return getYear
    }
    
    init(dict: NSDictionary) {
        revenue = dict.getStringValue(key: "revenue")
        month = Date.dateFromAppServerFormatMonth(from: dict.getStringValue(key: "month"))
        year = Date.dateFromAppServerFormatYear(from: dict.getStringValue(key: "year"))
    }
}


class Month1{
    var revenue : String
    var startWeek : Date?
    var endWeek : Date?
    var year : Date?
    
    var strStartWeek : String{
        let getStartWeek = Date.localDateString(from: startWeek, format: "dd-MM")
        
        return getStartWeek
    }
    
    var strEndWeek : String{
        let getEndWeek = Date.localDateString(from: endWeek, format: "dd-MM")
        
        return getEndWeek
    }
    
    var strYear : String{
        let getYear =  Date.localDateString(from: year, format: "yyyy")
        return getYear
    }
    
    var strCombine : String{
        let combine = strStartWeek + "|" + strEndWeek
        return combine
    }
    
    init(dict : NSDictionary) {
        revenue = dict.getStringValue(key: "revenue")
        startWeek = Date.dateFromAppServerFormatDeshFormat(from: dict.getStringValue(key: "start_week"))
        endWeek = Date.dateFromAppServerFormatDeshFormat(from: dict.getStringValue(key: "end_week"))
        year = Date.dateFromAppServerFormatYear(from: dict.getStringValue(key: "year"))
    }
}


class Week1{
    var revenue : String
    var weekDayDate : Date?
    var year : Date?
    
    var strDate : String{
        let getMonth = Date.localDateString(from: weekDayDate, format: "dd-MM")
        return getMonth
    }
    var strYear : String{
        let getYear =  Date.localDateString(from: year, format: "yyyy")
        return getYear
    }
    
    init(dict : NSDictionary) {
        revenue = dict.getStringValue(key: "revenue")
        weekDayDate = Date.dateFromAppServerFormatDeshFormat(from: dict.getStringValue(key: "date"))
        year = Date.dateFromAppServerFormatYear(from: dict.getStringValue(key: "year"))
    }
}


//MARK:- Driver Revenue Details
class DriverRevenue{
    var totalRevenue : String
    var serviceId : String
    var mostBookedService : MostBookedServices?
    
    init(dict: NSDictionary) {
        totalRevenue = dict.getStringValue(key: "total_revenue")
        serviceId = dict.getStringValue(key: "service_id")
        if let serviceDict = dict["service"] as? NSDictionary{
            self.mostBookedService = MostBookedServices(dict: serviceDict)
        }
    }
}

class MostBookedServices{
    var name : String
    var price : String
    var id : String
    
    
    init(dict : NSDictionary) {
        name = dict.getStringValue(key: "name")
        price = dict.getStringValue(key: "price")
        id = dict.getStringValue(key: "id")
    }
}
