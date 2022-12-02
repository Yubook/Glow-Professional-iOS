//
//  TermsAndConditionData.swift
//  GlowPro
//
//  Created by Chirag Patel on 10/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation

class Terms{
    let id : String
    var type : String
    var content : String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        type = dict.getStringValue(key: "type")
        content = dict.getStringValue(key: "content")
    }
}
