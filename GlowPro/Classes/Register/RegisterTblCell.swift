//
//  RegisterTblCell.swift
//  GlowPro
//
//  Created by MutipzTechnology on 30/03/22.
//  Copyright © 2022 Devang Lakhani. All rights reserved.
//

import UIKit
import DropDown

class RegisterTblCell: UITableViewCell {
    @IBOutlet weak var tfInputText: UITextField!
    @IBOutlet weak var tfEmailText: UITextField!
    @IBOutlet weak var tfIcon : UIImageView!
    @IBOutlet weak var tfInputPhone : UITextField!
    @IBOutlet weak var lblCountryCode : UILabel!
    @IBOutlet weak var btnMale : UIButton!
    @IBOutlet weak var btnFemale : UIButton!
    @IBOutlet weak var tfBrberId : UITextField!
    @IBOutlet weak var tfBarberAddress : UITextField!
    @IBOutlet weak var lblPlaceholderIcon: UILabel!
    @IBOutlet weak var imgPlaceholderId : UIImageView!
    @IBOutlet weak var lblTextPlace : UILabel!
    @IBOutlet weak var imgPlaceHolderAdd : UIImageView!
    @IBOutlet weak var lblDropdownVal : UILabel!
    @IBOutlet weak var imgProofId : UIImageView!
    @IBOutlet weak var imgAddressProof : UIImageView!
    @IBOutlet weak var btnDropDown : UIButton!
    @IBOutlet weak var dropview : UIView!
    weak var parentRegister : RegisterVC!
    var selectedIndex = 0
}

//MARK: - Prepare Cell Methods
extension RegisterTblCell{
    func configCellData(data: RegisterModal, idx: Int){
        switch data.cellType{
        case .textFieldCell:
            tfInputText.placeholder = data.placeHolderName
            tfInputText.keyboardType = data.tfKeyboardType
            tfInputText.returnKeyType = data.tfReturnType
            tfIcon.image = data.textFiledIcon
            tfInputText.tag = idx
            tfInputText.text = data.value
        case .textEmailCell:
            tfInputText.placeholder = data.placeHolderName
            tfInputText.keyboardType = data.tfKeyboardType
            tfInputText.returnKeyType = data.tfReturnType
            tfIcon.image = data.textFiledIcon
            tfInputText.tag = idx
            tfInputText.text = data.value
        case .phoneCell:
            tfInputPhone.isEnabled = false
            tfInputPhone.text = parentRegister.phoneNumber
            let countryCode = _userDefault.value(forKey: "countryCode")
            self.lblCountryCode.text = "\(countryCode!)"
            self.lblCountryCode.textAlignment = .center
        case .proofCell:
            tfBrberId.text = "Proof of ID"
            tfBarberAddress.text = "Proof of address"
        case .imgCell:
            imgPlaceholderId.isHidden = imgProofId.image == nil ? false : true
            lblPlaceholderIcon.isHidden = imgProofId.image == nil ? false : true
            imgPlaceHolderAdd.isHidden = imgAddressProof.image == nil ? false : true
            lblTextPlace.isHidden = imgAddressProof.image == nil ? false : true
        case .dropdownCell:
            lblDropdownVal.text = data.dropDownValue == "" ? data.dropDownPlaceholder : data.dropDownValue
            if lblDropdownVal.text == "City *" {
                lblDropdownVal.textColor = .gray
            } else  {
                lblDropdownVal.textColor = .black
            }
            
            btnDropDown.tag = idx
        default : break
        }
    }
}

//MARK: - Others Methods
extension RegisterTblCell{
    @IBAction func tfInputChanged(_ textField: UITextField){
        if let str = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            parentRegister.objRegisterData.arrData[textField.tag].value = str
        }
    }
    
    @IBAction func tfInputIdChanged(_ textField: UITextField){
        if let str = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            parentRegister.proofId = str
            parentRegister.objRegisterData.arrData[7].vlaueOfId = str
        }
    }
    
    @IBAction func tfAddressProofChange(_ textField: UITextField){
        if let str = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            parentRegister.address = str
            parentRegister.objRegisterData.arrData[7].address = str
        }
    }
    
    @IBAction func btnProofIdTapped(_ sender: UIButton){
        selectedIndex = 0
        let pickerVC = UIImagePickerController()
        parentRegister.prepareImagePicker(pictureController: pickerVC)
        pickerVC.delegate = self
    }
    
    @IBAction func btnAddressProofTapped(_ sender: UIButton){
        selectedIndex = 1
        let pickerVC = UIImagePickerController()
        parentRegister.prepareImagePicker(pictureController: pickerVC)
        pickerVC.delegate = self
    }
    
    @IBAction func btnDropDownTapped(_ sender: UIButton){
        let dropDown = DropDown()
        if sender.tag == 9{
            dropDown.dataSource = parentRegister.arrState.map{$0.name}
        }else{
            dropDown.dataSource = parentRegister.arrCity.map{$0.name}
        }
        dropDown.textColor = .black
        dropDown.cellHeight = 40
        dropDown.direction = .bottom
        dropDown.backgroundColor = .white
        dropDown.layer.cornerRadius = 8
        dropDown.anchorView = dropview
        dropDown.bottomOffset = CGPoint(x: 0, y: dropview.frame.size.height)
        dropDown.show()
        dropDown.selectionAction = { (index: Int, item: String) in
            if sender.tag == 9{
                let id = self.parentRegister.arrState[index].id
                self.parentRegister.objRegisterData.arrData[sender.tag].dropDownId = Int(id)!
            }else{
                let id = self.parentRegister.arrCity[index].id
                self.parentRegister.objRegisterData.arrData[sender.tag].dropDownId = Int(id)!
            }
            self.parentRegister.objRegisterData.arrData[sender.tag].dropDownValue = item
            self.parentRegister.tableView.reloadData()
        }
    }
    
    @IBAction func btnGenderTapped(_ sender: UIButton){
        btnMale.isSelected.toggle()
        btnFemale.isSelected.toggle()
        if btnMale.isSelected{
            parentRegister.objRegisterData.arrData[7].value = "male"
            btnFemale.isSelected = false
            btnFemale.isSelected = false
        }else{
            parentRegister.objRegisterData.arrData[7].value = "female"
            btnFemale.isSelected = true
        }
    }
}

//MARK: - UIImagePickerDelegate Methods
extension RegisterTblCell : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            if selectedIndex == 0{
                imgProofId.contentMode = .scaleAspectFill
                imgProofId.image = image
                parentRegister.proofIdImg = image
            }else{
                imgAddressProof.contentMode = .scaleAspectFill
                parentRegister.addressImg = image
                imgAddressProof.image = image
            }
            parentRegister.tableView.reloadData()
            parentRegister.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parentRegister.dismiss(animated: true, completion: nil)
    }
}
