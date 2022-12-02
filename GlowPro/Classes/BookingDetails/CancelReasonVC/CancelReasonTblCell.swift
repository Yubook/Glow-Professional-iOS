//
//  CancelReasonTblCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class CancelReasonTblCell: UITableViewCell {
    @IBOutlet weak var lblReason : UILabel!
    @IBOutlet weak var imgReason : UIImageView!
    @IBOutlet weak var imgOther : UIImageView!
    @IBOutlet weak var txtView : UITextView!
    @IBOutlet weak var lblPlaceHolder : UILabel!
    
    weak var parent : CancelReasonVC!
    
    func prepareTextView(){
        txtView.isHidden = true
        txtView.layer.cornerRadius = 20
        txtView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
    
    func prepareCell(data: CancelReason){
        
        
        lblReason.text = data.reasonName
        imgReason.tintColor = #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)
        imgReason.image = UIImage(named: data.isSelected ? "ic_radio_btn" : "ic_radio_round")
    }
    
    func prepareOtherCell(){
        txtView.isHidden = parent.isOtherSelected ? false : true
        lblPlaceHolder.isHidden = parent.isOtherSelected ? false : true
    }

}
//MARK:- TextView Delegate Methods
extension CancelReasonTblCell : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if let str = textView.text{
            if str.count > 0{
                lblPlaceHolder.isHidden = true
                parent.reasonMsg = str
            }else{
                lblPlaceHolder.isHidden = false
            }
        }
    }
}
