//
//  EditProfileTblCell.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/14/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class EditProfileTblCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var tfInputLocation : UITextField!
    @IBOutlet weak var tfInputPhone : UITextField!
    @IBOutlet weak var imgRighttfView : UIImageView!
    @IBOutlet weak var btnMale : UIButton!
    @IBOutlet weak var btnFemale : UIButton!
    
    weak var parentVC : EditProfileVC!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func prepareCell(data: EditProfileModel, index: Int){
        switch data.cellType{
        case .textFieldCell :
            tfInput.placeholder = data.placeHolderTitle
            tfInput.keyboardType = data.keyboardType
            tfInput.returnKeyType = data.returnKeyType
            tfInput.text = data.value
            tfInput.tag = index
            imgRighttfView.image = data.profileImage
            prepareTextField(txtField: tfInput)
        case .phoneCell:
            tfInputPhone.text = data.value
        case .locationCell:
            tfInputLocation.isUserInteractionEnabled = false
            prepareTextField(txtField: tfInputLocation)
        case .genderCell:
            if parentVC.isEdit{
                if data.value == "male"{
                    btnFemale.isSelected = false
                    btnMale.isSelected = true
                }else{
                    btnMale.isSelected = false
                    btnFemale.isSelected = true
                }
            }
            
        default : break
        }
    }
    
    func prepareTextField(txtField : UITextField){
        txtField.layer.cornerRadius = 12
        txtField.layer.borderWidth = 1.0
        txtField.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)
    }
    
    func disableText(data: EditProfileModel, index: Int){
        if data.cellType == .textFieldCell && index == 1{
            tfInput.isUserInteractionEnabled = false
            tfInput.alpha = 0.5
        }
    }
}

//MARK:- Gender Selection Methods
extension EditProfileTblCell{
    @IBAction func btnGenderTapped(_ sender: UIButton){
        btnMale.isSelected.toggle()
        btnFemale.isSelected.toggle()
        if btnMale.isSelected{
            parentVC.objModel.arrEditProfileData[2].value = "male"
            btnFemale.isSelected = false
        }else{
            parentVC.objModel.arrEditProfileData[2].value = "female"
            btnFemale.isSelected = true
        }
    }
}

//MARK:- TextField Editing Changed Methods
extension EditProfileTblCell{
    @IBAction func tfInputDidChanged(_ textField : UITextField){
        if let strValue = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            self.parentVC.objModel.arrEditProfileData[textField.tag].value = strValue
        }
    }
}
