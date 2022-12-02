//
//  Login.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/8/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit

enum EnumLogin{
    case imgaeCell
    case instructionCell
    case txtFieldCell
    case btnCell
    
    var cellId: String{
        switch self{
        case .imgaeCell:
            return "backScreenCell"
        case .instructionCell:
            return "instructionCell"
        case .txtFieldCell:
            return "txtFieldCell"
        case .btnCell:
            return "btnCell"
        }
    }
    
    var cellHeight : CGFloat{
        switch self{
        case .imgaeCell,.instructionCell,.btnCell,.txtFieldCell :
            return UITableView.automaticDimension
        }
    }
}

struct LoginModel {
    var value : String = ""
    var cellType : EnumLogin = .instructionCell
    var placeHolderTitle : String = ""
    var keyboardType : UIKeyboardType = .default
    var keyboardAppearance : UIKeyboardAppearance = .light
}

class Login{
    var arrData : [LoginModel] = []
    
    func prepareData(){
        var f0 = LoginModel()
        f0.cellType = .imgaeCell
        self.arrData.append(f0)
        
        var f2 = LoginModel()
        f2.placeHolderTitle = "Mobile Number"
        f2.keyboardType = .phonePad
        f2.keyboardAppearance = .light
        f2.cellType = .txtFieldCell
        self.arrData.append(f2)
        
        var f1 = LoginModel()
        f1.cellType = .instructionCell
        self.arrData.append(f1)
        
        var f4 = LoginModel()
        f4.cellType = .btnCell
        self.arrData.append(f4)
    }
    
    func validatetData() -> (isValid: Bool, error: String) {
        var result = (isValid: true, error: "")
        if String.validateStringValue(str: arrData[1].value) {
            result.isValid = false
            result.error = kEnterMobile
        } else if !arrData[1].value.validateContact() {
            result.isValid = false
            result.error = kMobileInvalid
        }
        return result
    }
}
