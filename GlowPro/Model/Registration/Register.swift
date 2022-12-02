//
//  Register.swift
//  GlowPro
//
//  Created by MutipzTechnology on 30/03/22.
//  Copyright © 2022 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumRegister{
    case textFieldCell
    case textEmailCell
    case phoneCell
    case genderCell
    case proofCell
    case imgCell
    case dropdownCell
    
    var cellId : String{
        switch self {
        case .textFieldCell:
            return "textFiledCell"
        case .textEmailCell:
            return "textFiledCell"
        case .phoneCell:
            return "phoneCell"
        case .genderCell:
            return "genderCell"
        case .proofCell:
            return "idCell"
        case .imgCell:
            return "imgCell"
        case .dropdownCell:
            return "dropdownCell"
        }
    }
    
    var cellHegiht: CGFloat{
        switch self {
        case .textFieldCell,.phoneCell,.textEmailCell,.proofCell,.imgCell,.dropdownCell:
            return UITableView.automaticDimension
        case .genderCell:
            return 60.widthRatio
        }
    }
}

struct RegisterModal{
    var placeHolderName : String = ""
    var textFiledIcon : UIImage!
    var value : String = ""
    var dropDownPlaceholder: String = ""
    var dropDownValue : String = ""
    var tfReturnType : UIReturnKeyType  = .default
    var tfKeyboardType : UIKeyboardType = .default
    var vlaueOfId : String = ""
    var address : String = ""
    var dropDownId : Int = 0
    var cellType : EnumRegister = .textFieldCell
}

class Register{
    var arrData : [RegisterModal] = []
    
    func prepareData(){
        var objBarberName = RegisterModal()
        objBarberName.placeHolderName = "Barber Name *"
        objBarberName.tfReturnType = .next
        objBarberName.tfKeyboardType = .default
        objBarberName.textFiledIcon = UIImage(named: "ic_user_new")
        objBarberName.cellType = .textFieldCell
        self.arrData.append(objBarberName)
        
        var objBarberAddress = RegisterModal()
        objBarberAddress.placeHolderName = "Address Line 1 *"
        objBarberAddress.tfReturnType = .next
        objBarberAddress.tfKeyboardType = .default
        objBarberAddress.textFiledIcon = UIImage(named: "ic_location")
        objBarberAddress.cellType = .textFieldCell
        self.arrData.append(objBarberAddress)
        
        var objBarberAddress1 = RegisterModal()
        objBarberAddress1.placeHolderName = "Address Line 2"
        objBarberAddress1.tfReturnType = .next
        objBarberAddress1.tfKeyboardType = .default
        objBarberAddress1.textFiledIcon = UIImage(named: "ic_location")
        objBarberAddress1.cellType = .textFieldCell
        self.arrData.append(objBarberAddress1)
        
        var objPostcode = RegisterModal()
        objPostcode.placeHolderName = "Postcode"
        objPostcode.tfReturnType = .done
        objPostcode.tfKeyboardType = .phonePad
        objPostcode.textFiledIcon = UIImage(named: "ic_postcode_new")
        objPostcode.cellType = .textFieldCell
        self.arrData.append(objPostcode)
        
        var objCity = RegisterModal()
        objCity.dropDownPlaceholder = "City *"
        objCity.cellType = .dropdownCell
        self.arrData.append(objCity)
        
        var objEmail = RegisterModal()
        objEmail.placeHolderName = "Email"
        objEmail.tfReturnType = .done
        objEmail.tfKeyboardType = .emailAddress
        objEmail.textFiledIcon = UIImage(named: "ic_email")!.withTintColor(.black)
        objEmail.cellType = .textEmailCell
        self.arrData.append(objEmail)
        
        var objPhoneNo = RegisterModal()
        objPhoneNo.placeHolderName = "PhoneNo"
        objPhoneNo.cellType = .phoneCell
        self.arrData.append(objPhoneNo)
        
        
        var objGender = RegisterModal()
        objGender.placeHolderName = "Gender"
        objGender.cellType = .genderCell
        self.arrData.append(objGender)
        
        var objProofCell = RegisterModal()
        objProofCell.placeHolderName = "Proofe"
        objProofCell.cellType = .proofCell
        self.arrData.append(objProofCell)
        
        var objImage = RegisterModal()
        objImage.placeHolderName = "ProofImage"
        objImage.cellType = .imgCell
        self.arrData.append(objImage)
        
//        var f10 = RegisterModal()
//        f10.dropDownPlaceholder = "State *"
//        f10.cellType = .dropdownCell
//        self.arrData.append(f10)
//
//        var f11 = RegisterModal()
//        f11.dropDownPlaceholder = "City *"
//        f11.cellType = .dropdownCell
//        self.arrData.append(f11)
    }
    
//    func validateRegisterDetails() -> (isValid : Bool, error: String){
//        var result = (valid: false,errors: "")
//        if String.validateStringValue(str: arrData[0].value){
//            result.valid = true
//            result.errors = ""
//        }else{
//            result.valid = false
//            result.errors = "Please Enter Name"
//        }
//        return result
//    }
}


class State{
    var id: String
    var name : String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
    }
}

class City{
    var id: String
    var name : String
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
    }
}
