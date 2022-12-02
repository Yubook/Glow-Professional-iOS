//
//  PaymentHistoryTblCell.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/14/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class PaymentHistoryTblCell: UITableViewCell {
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblServiceName : UILabel!
    @IBOutlet weak var lblTimeDate : UILabel!
    @IBOutlet weak var lblTotalPrice : UILabel!
    
    func preparePaymnetCell(data: Orders){
        if data.isOrderCompleted == 1{
            lblTotalPrice.textColor = #colorLiteral(red: 0.2745098039, green: 0.7333333333, blue: 0.2235294118, alpha: 1)
        }else if data.isOrderCompleted == 2{
            lblTotalPrice.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        lblTotalPrice.text = "£ " + data.amount
        if let userData = data.userDetail{
            imgUser.kf.setImage(with: userData.imgUrl)
            lblUserName.text = userData.name
        }
        var strServices : String{
            let strList = data.arrServices.map{$0.name}.filter{!$0.isEmpty}.joined(separator: ",")
            return strList
        }
        lblServiceName.text = strServices
        if !data.arrServices.isEmpty{
            let obj = data.arrServices.first!
            lblTimeDate.text = obj.strDate +  convertFormat(time: obj.slotTime)
        }
    }
}

extension PaymentHistoryTblCell{
    func convertFormat(time: String) -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        let showDate = inputFormatter.date(from: time)
        inputFormatter.dateFormat = "HH:mm a"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
}
