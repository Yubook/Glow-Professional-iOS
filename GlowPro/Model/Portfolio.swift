//
//  Portfolio.swift
//  GlowPro
//
//  Created by Chirag Patel on 02/12/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation

enum EnumPortfolio{
    case barber
    case user
    
    init(val : Int) {
        if val == 0{
            self = .barber
        }else{
            self = .user
        }
    }
}

class Portfolio{
    let id : String
    var img : String
    
    var imgUrl : URL?{
        return URL(string: _storage + img)
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        img = dict.getStringValue(key: "path")
    }
}
