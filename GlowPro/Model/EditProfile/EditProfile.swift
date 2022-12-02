//
//  EditProfile.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/14/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumEditProfile{
    case textFieldCell
    case genderCell
    case phoneCell
    case locationCell
    case btnCell
    
    var cellId: String{
        switch self{
        case .textFieldCell:
            return "txtFieldCell"
        case .genderCell:
            return "genderCell"
        case .phoneCell:
            return "phoneCell"
        case .locationCell:
            return "locationCell"
        case .btnCell:
            return "btnCell"
        }
    }
    
    var cellHeight : CGFloat{
        switch self{
        case .textFieldCell:
            return 75.widthRatio
        case .genderCell:
            return 58.widthRatio
        case .phoneCell:
            return 90.widthRatio
        case .locationCell:
            return 64.widthRatio
        case .btnCell:
            return 60.widthRatio
        }
    }
}

struct EditProfileModel{
    var placeHolderTitle : String = ""
    var keyboardType : UIKeyboardType = .default
    var returnKeyType : UIReturnKeyType = .default
    var value : String = ""
    var cellType : EnumEditProfile = .textFieldCell
    var profileImage : UIImage!
    var isGenderSelected = false
}

class EditProfile{
    var arrEditProfileData : [EditProfileModel] = []
    
    func prepareData(){
        var f0 = EditProfileModel()
        if _user != nil{
            f0.value = _user.name
        }
        f0.placeHolderTitle = "Name"
        f0.profileImage = UIImage(named: "ic_users")
        f0.keyboardType = .default
        f0.returnKeyType = .next
        f0.cellType = .textFieldCell
        self.arrEditProfileData.append(f0)
        
        var f1 = EditProfileModel()
        if _user != nil{
            f1.value = _user.email
        }
        f1.placeHolderTitle = "Email"
        f1.profileImage = UIImage(named: "ic_email")
        f1.keyboardType = .emailAddress
        f1.returnKeyType = .done
        f1.cellType = .textFieldCell
        self.arrEditProfileData.append(f1)
        
        var f6 = EditProfileModel()
        if _user != nil{
            f6.value = _user.gender
        }
        f6.cellType = .genderCell
        self.arrEditProfileData.append(f6)
        
        var f3 = EditProfileModel()
        f3.profileImage = UIImage(named: "ic_call")
        f3.cellType = .phoneCell
        self.arrEditProfileData.append(f3)
        
       /* var f2 = EditProfileModel()
        if _user != nil{
            f2.value = _user.vanNumber
        }
        f2.placeHolderTitle = "Van Number"
        f2.profileImage = UIImage(named: "ic_van")
        f2.keyboardType = .default
        f2.returnKeyType = .done
        f2.cellType = .textFieldCell
        self.arrEditProfileData.append(f2) */
        
        var f4 = EditProfileModel()
        f4.cellType = .locationCell
        self.arrEditProfileData.append(f4)
        
        var f5 = EditProfileModel()
        f5.cellType = .btnCell
        self.arrEditProfileData.append(f5)
    }
    
    func validateData() -> (isValid : Bool, error : String){
        var result = (isValid : true, error : "")
        
        if String.validateStringValue(str: arrEditProfileData[0].value){
            result.isValid = false
            result.error = kEnterName
        }else if String.validateStringValue(str: arrEditProfileData[1].value){
            result.isValid = false
            result.error = kEnterEmail
        }else if !arrEditProfileData[1].value.isValidEmailAddress(){
            result.isValid = false
            result.error = kInvalidEmail
        }
        return result
    }
}
