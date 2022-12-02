//
//  ProfileTblCell.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/13/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ProfileTblCell: UITableViewCell {
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var lblFeature : UILabel!
    @IBOutlet weak var availablitySwitch : UISwitch!
    
    func prepareCell(data: ProfileDetails){
        if data.featuresName != "Availability"{
            self.accessoryType = .disclosureIndicator
            availablitySwitch.isHidden = true
        }else{
            self.accessoryType = .none
            availablitySwitch.isHidden = false
            if _userDefault.integer(forKey: "availablity") == 1{
                availablitySwitch.isOn = true
            }else{
                availablitySwitch.isOn = false
            }
        }
        imgView.image = data.setIcon
        lblFeature.text = data.featuresName
    }
    
}
