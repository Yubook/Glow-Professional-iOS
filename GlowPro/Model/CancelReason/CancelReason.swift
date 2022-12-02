//
//  CancelReason.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

class CancelReason{
    let id : String
    var reasonName : String
    var isSelected : Bool = false
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        reasonName = dict.getStringValue(key: "reason")
    }
}
