//
//  CountryList.swift
//  GlowPro
//
//  Created by MutipzTechnology on 15/10/22.
//  Copyright © 2022 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

class CountryList{
    var id : String
    var countryName : String
    var countryISO2 : String
    var countryCurrency : String
    var countryPhoneCode : String
    var countryStatus : String
    var countryFlag : String

    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        countryName = dict.getStringValue(key: "name")
        countryISO2 = dict.getStringValue(key: "iso2")
        countryCurrency = dict.getStringValue(key: "currency")
        countryPhoneCode = dict.getStringValue(key: "phonecode")
        countryStatus = dict.getStringValue(key: "active")
        countryFlag = dict.getStringValue(key: "emoji")
    }
}

