//
//  Messages.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/14/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumMsgType : Int{
    case withoutImage = 1
    case withImage = 2
    
    var cellHeight: CGFloat {
        switch self {
        case .withImage:
            return 250.widthRatio
        default:
            return UITableView.automaticDimension
        }
    }
}


enum EnumMessages{
    case timeCell
    case senderCell
    case receivedCell
    case senderImage
    case receivedImage
    
    var cellId: String{
        switch self{
        case .timeCell:
            return "timeCell"
        case .senderCell:
            return "senderCell"
        case .receivedCell:
            return "receivedCell"
        case .senderImage:
            return "senderImageCell"
        case .receivedImage:
            return "receivedImageCell"
        }
    }
    
    var cellHeight : CGFloat{
        switch self{
        case .timeCell:
            return 44.widthRatio
        case .senderCell:
            return 130.widthRatio
        case .receivedCell:
            return 124.widthRatio
        case .senderImage,.receivedImage:
            return 200.widthRatio
        }
    }
}

class MessageSection {
    let date: Date
    var msgs: [Message] = []
    
    init(msg: [Message]) {
        date = msg.first!.msgDate!
        msgs = msg
    }
}

class Message {
    
    let id: String
    let userId: String
    let groupId: String
    let message: String
    let fileName: String
    let type: EnumMsgType
    let isRead: Bool
    var progress: CGFloat = 0
    var msgDate: Date?

    var isSenderMsg: Bool {
        return userId == _user.id
    }
    
    var isMediaMsg: Bool {
        return type == .withImage
    }
    
    var mediaUrl: URL? {
        return URL(string: fileName)
    }
    
    var strTime: String {
        return msgDate!.stringOfCurrentTime12HoursFormat()
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        userId = dict.getStringValue(key: "user_id")
        groupId = dict.getStringValue(key: "group_id")
        message = dict.getStringValue(key: "message")
        fileName = dict.getStringValue(key: "filename")
        type = EnumMsgType(rawValue: dict.getIntValue(key: "type")) ?? .withoutImage
        isRead = dict.getBooleanValue(key: "is_read")
        msgDate = Date.getISODateFormatConvertor(from: dict.getStringValue(key: "created_at"))
    }
}
