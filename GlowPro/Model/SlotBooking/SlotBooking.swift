//
//  SlotBooking.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
class AvailableSlots{
    let id : String
    var time : String
    var section : String
    var isSelected = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        time = dict.getStringValue(key: "time")
        section = dict.getStringValue(key: "section")
    }
}

class SelectedDates{
    var dates : Date
    var strDate : String
    var isSelected = false
    
    init(date: Date,str: String) {
        self.dates = date
        self.strDate = str
    }
}
