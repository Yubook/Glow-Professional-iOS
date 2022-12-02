//
//  Home.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumHome{
    case revenueCell
    case bookingStateCell
    case reviewsCell
    case inProgessCell
    case gallaryCell
    
    var cellId: String{
        switch self{
        case .revenueCell:
            return "revenueCell"
        case .bookingStateCell:
            return "bookingStateCell"
        case .reviewsCell:
            return "reviewsStatesCell"
        case .inProgessCell:
            return "inProgressBookingCell"
        case .gallaryCell:
            return "gallaryCell"
        }
    }
    
    var cellHeight : CGFloat{
        switch self{
        case .revenueCell,.bookingStateCell,.reviewsCell:
            return 250.widthRatio
        case .inProgessCell:
            return 180.widthRatio
        case .gallaryCell:
            return 130.widthRatio
        }
    }
    
    var sectionTitle : String{
        switch self{
        case .revenueCell:
            return "Revenue"
        case .bookingStateCell:
            return "Booking State"
        case .reviewsCell:
            return "Reviews States"
        case .inProgessCell:
            return "In progress Booking"
        case .gallaryCell:
            return "Gallery"
        }
    }
}
