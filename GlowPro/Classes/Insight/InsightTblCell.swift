//
//  InsightTblCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class InsightTblCell: UITableViewCell {
    @IBOutlet weak var lblServiceName : UILabel!
    @IBOutlet weak var lblTotalRevenue : UILabel!
    @IBOutlet weak var lblDateTime : UILabel!

    func prepareCell(data: PreviousBooking){
        lblTotalRevenue.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        let services = data.arrServices.map{$0.name}.filter{!$0.isEmpty}.joined(separator: ",")
        lblServiceName.text = services
        lblTotalRevenue.text = "£ " + data.totalPay
        if !data.arrServices.isEmpty{
            let firstService = data.arrServices.first!
            lblDateTime.text = firstService.strRevenueDate + convertFormat(time: firstService.slotTime)
        }
    }
    
    func convertFormat(time: String) -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        let showDate = inputFormatter.date(from: time)
        inputFormatter.dateFormat = "hh:mm a"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
}
