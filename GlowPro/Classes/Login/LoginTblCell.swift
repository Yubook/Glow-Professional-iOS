//
//  LoginTblCell.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/8/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import FittedSheets

class LoginTblCell: UITableViewCell {
    @IBOutlet weak var tfInput : UITextField!
    @IBOutlet weak var btnCountrySelection : UIButton!
    @IBOutlet weak var lblCountryCode : UILabel!
    @IBOutlet weak var lblCountryFlag : UILabel!

    weak var parentVC : LoginVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareCell(data: LoginModel, index: Int){
        switch data.cellType{
        case .txtFieldCell:
            tfInput.placeholder = data.placeHolderTitle
            tfInput.keyboardType = data.keyboardType
            tfInput.keyboardAppearance = data.keyboardAppearance
            tfInput.text = data.value
            tfInput.tag = index
            if self.lblCountryCode.text == "" {
                self.lblCountryCode.text = "+44"
                self.lblCountryFlag.text = "🇬🇧"
                _userDefault.set("232", forKey: "countryID")
                _userDefault.set("+44", forKey: "countryCode")
            }
        default: break
        }
    }
}


//MARK:- Textfiled Editing Changed Action Methods
extension LoginTblCell {
    
}
//MARK:- Textfiled Editing Changed Action Methods
extension LoginTblCell : UITextFieldDelegate {
    @IBAction func tfInputChanged(_ textField: UITextField){
        if let str = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            self.parentVC.objData.arrData[textField.tag].value = str
            if str.count == 10 {
                textField.resignFirstResponder()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text! + string
        if str.count > 10 {
            return false
        }
        let cs = NSCharacterSet(charactersIn: "0123456789").inverted
        let filStr = string.components(separatedBy: cs).joined(separator: "")
        return string == filStr
    }
    
    @IBAction func btnCountryCodeTapped(_ sender: UIButton){
        let vc = UIStoryboard(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "CountryVC") as! CountryVC
        vc.completionCountrySelection = { countryObj in
            self.lblCountryCode.text = "+\(countryObj.countryPhoneCode)"
            self.lblCountryFlag.text = countryObj.countryFlag
            _userDefault.set("+\(countryObj.countryPhoneCode)", forKey: "countryCode")
            _userDefault.value(forKey: "countryPhoneCode")
            _userDefault.set(countryObj.id, forKey: "countryID")
        }
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
}

