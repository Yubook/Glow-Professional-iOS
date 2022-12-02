//
//  ChatListTblCell.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/13/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ChatListTblCell: UITableViewCell {
    @IBOutlet weak var statusView : UIView!
    @IBOutlet weak var imgProfileView : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblLastMessage : UILabel!
    @IBOutlet weak var lblRoleName : UILabel!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var messageCounter : UIView!
    
    func prepareInboxUI(data : UserChat){
        imgProfileView.kf.indicatorType = .activity
        imgProfileView.kf.setImage(with: data.profileUrl, placeholder: _placeImageUser)
        lblName.text = data.name
        statusView.backgroundColor = data.statusColor
        lblLastMessage.text = data.activeStatus
        messageCounter.isHidden = data.unreadCount == 0
        lblCount.text = "\(data.unreadCount)"
    }

}
