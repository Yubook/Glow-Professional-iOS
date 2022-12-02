//
//  BookingDetailsTblCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/16/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class BookingDetailsTblCell: UITableViewCell {
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var imgUserProfile : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblBookedService : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var lblDateTime : UILabel!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblUserBookedService : UILabel!
    @IBOutlet weak var lblBookingAmount : UILabel!
    @IBOutlet weak var lblBookingDateTime : UILabel!
    @IBOutlet weak var btnChat : UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var noDataView : UIView!
    @IBOutlet weak var lblNoData : UILabel!
    @IBOutlet weak var dataView : UIView!
    @IBOutlet weak var btnCompleted : UIButton!
    weak var parent : BookingDetailsVC!
    
    func currentCell(current : PreviousBooking){
        lblBookingAmount.text = "£\(current.totalPay)"
        imgUser.contentMode = .scaleAspectFit
        if let user = current.users{
            imgUser.contentMode = .scaleAspectFill
            lblUserName.text = user.name
            imgUser.kf.setImage(with: user.profileUrl)
        }
        var serviceList : String{
            let strService = current.arrServices.map{$0.name}.filter{!$0.isEmpty}.joined(separator: ",")
            return strService
        }
        lblUserBookedService.text = serviceList
        if !current.arrServices.isEmpty{
            let serviceFirst = current.arrServices.first!
            lblBookingDateTime.text = serviceFirst.strDate + convertFormat(time: serviceFirst.slotTime)
            var strsDate : String{
                let stringDate = Date.localDateString(from: serviceFirst.slotDate,format: "yyyy-MM-dd")
                return stringDate
            }
            var startOrderCompletedTime : String{
                var newTime = ""
                let subStr = serviceFirst.slotTime
                var time = subStr.prefix(2)
                if time.contains(":"){
                    time.removeLast()
                    newTime = "0" + time
                }
                let strTime = Int(newTime == "" ? String(time) : newTime)
                let firstTime = strTime! + 0
                let end = subStr.suffix(3)
                return strsDate + " " + "\(firstTime)"+"\(end)"
            }
            
            var endOrderTime : String{
                var newTime = ""
                let subStr = serviceFirst.slotTime
                var time = subStr.prefix(2)
                if time.contains(":"){
                    time.removeLast()
                    newTime = "0" + time
                }
                let strTime = Int(newTime == "" ? String(time) : newTime)
                let firstTime = strTime! + 1
                let end = subStr.suffix(3)
                return strsDate + " " + "\(firstTime)"+"\(end)"
            }
            
            let timeDate = serviceFirst.strDate + " " + parent.getSubStringTime(time: serviceFirst.slotTime)
            let timeDate1 = parent.getTodayDate()
            if timeDate < timeDate1{
                btnCancel.isEnabled = false
                btnCancel.backgroundColor =  #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            }else{
                btnCancel.isEnabled = true
                btnCancel.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)
                
            }
            if parent.cellType == .featureCell{
                btnCompleted.isEnabled = false
                btnCompleted.backgroundColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            }else if parent.cellType == .currentCell{
                if getTimeAndDate() > startOrderCompletedTime && getTimeAndDate() < endOrderTime{
                    btnCompleted.isEnabled = true
                    btnCompleted.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)
                }else{
                    btnCompleted.isEnabled = false
                    btnCompleted.backgroundColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
                }
            }
            if current.chat{
                btnChat.isEnabled = true
                btnChat.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)
            }else{
                btnChat.isEnabled = false
                btnChat.backgroundColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            }
        }
    }
    
    func previousCell(previous : PreviousBooking){
        if previous.isOrderCompleted == 1{
            lblStatus.text = "COMPLETED"
        } else if previous.isOrderCompleted == 2{
            lblStatus.text = "CANCEL"
        } else if previous.isOrderCompleted == 0{
            lblStatus.text = "INCOMPLETED"
        }
        lblAmount.text = "£\(previous.totalPay)"
        if let user = previous.users{
            imgUserProfile.contentMode = .scaleAspectFill
            lblName.text = user.name
            imgUserProfile.kf.setImage(with: user.profileUrl)
        }
        var serviceList : String{
            let strService = previous.arrServices.map{$0.name}.filter{!$0.isEmpty}.joined(separator: ",")
            return strService
        }
        lblBookedService.text = serviceList
        if !previous.arrServices.isEmpty{
            let serviceFirst = previous.arrServices.first!
            lblDateTime.text = serviceFirst.strDate + convertFormat(time: serviceFirst.slotTime)
        }
    }
}

extension BookingDetailsTblCell{
    func convertFormat(time: String) -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        let showDate = inputFormatter.date(from: time)
        inputFormatter.dateFormat = "HH:mm a"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    
    func getTimeAndDate() -> String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
