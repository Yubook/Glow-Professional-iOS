//
//  SelectServicesTblCell.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class SelectServicesTblCell: UITableViewCell {
    @IBOutlet weak var lblServiceName : UILabel!
    @IBOutlet weak var tfPriceInput : UITextField!
    @IBOutlet weak var selectedView : KPRoundView!
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var trailingConstraint : NSLayoutConstraint!
    @IBOutlet weak var lbltextField : UILabel!
    @IBOutlet weak var lblSymbol : UILabel!
    
    weak var parentVC : SelectServicesVC!
    
    
    func prepareServiceUI(data: Services,indx: Int){
        tfPriceInput.tag = indx
        if parentVC.isEdit{
            if data.price == ""{
                
                btnDelete.isHidden = true
                trailingConstraint.constant = 15
            }else{
                btnDelete.isHidden = false
                trailingConstraint.constant = 60
            }
            tfPriceInput.text = data.price
        }
//        lbltextField.isHidden = data.isSelected ? false : true
//        tfPriceInput.isHidden = data.isSelected ? false : true
//        lblSymbol.isHidden = data.isSelected ? false : true
        lblServiceName.textColor = data.isSelected ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.7058823529, green: 0.7058823529, blue: 0.7058823529, alpha: 1)
        selectedView.borderColor = data.isSelected ? #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1) : #colorLiteral(red: 0.7058823529, green: 0.7058823529, blue: 0.7058823529, alpha: 1)
        lblServiceName.text = data.name
        tfPriceInput.keyboardType = .phonePad
        tfPriceInput.resignFirstResponder()
        if data.isSelected{
            DispatchQueue.main.async { [self] in
                tfPriceInput.becomeFirstResponder()
            }
        }
    }
}

//MARK:- TextField Editing Changed Methods
extension SelectServicesTblCell : UITextFieldDelegate{
    @IBAction func tfInputChanged(_ textField: UITextField){
        if let strtext = textField.text?.trimmedString(){
            parentVC.arrServices[textField.tag].price = strtext
        }
    }
}
