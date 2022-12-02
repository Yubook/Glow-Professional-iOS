//
//  BookingDetailsVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/16/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class BookingDetailsVC: ParentViewController {
    
    @IBOutlet weak var bookingSegment : UISegmentedControl!
    var cellType : EnumBookingDetails = .previousCell
    var objBookingData : BookingList?
    var orderId : String = ""
    var isBack : Bool = false
    var todayDate = Date()
    var isChatEnable = false
    
    var arrFilterCurrentBooking : [PreviousBooking]{
        return objBookingData!.arrCurrentBooked.filter{$0.isOrderCompleted == 0}
    }
    var arrFilterFutureBooking : [PreviousBooking]{
        return objBookingData!.arrFeatureBooked.filter{$0.isOrderCompleted == 0}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // getBookings()
        prepareUI()
        getNoDataCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.scrollToTop(animate: true)
        getBookings()
    }
    
    
}

//MARK:- Others Methods
extension BookingDetailsVC{
    func prepareUI(){
        prepareSegment()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: _tabBarHeight + 10, right: 0)
    }
    
    func prepareSegment() {
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)]
        bookingSegment.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        bookingSegment.setTitleTextAttributes(normalTextAttributes, for: .normal)
    }
    
    @IBAction func segmentTapped(_ segment: UISegmentedControl){
        self.cellType = EnumBookingDetails(idx: segment.selectedSegmentIndex)
        prepareSegment()
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @IBAction func btnCancleTapped(_ sender: UIButton){
        prepareReasonView(index: sender.tag, cellType: cellType)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customerDetails"{
            let vc = segue.destination as! CustomerBookingDetailsVC
            vc.cellSelectedType = self.cellType
            vc.isChatOn = isChatEnable
            vc.objCustomerData = (sender as! PreviousBooking)
        }
    }
    
    @IBAction func btnCompletedTapped(_ sender: UIButton){
        if objBookingData != nil{
            let objCurr = arrFilterCurrentBooking[sender.tag]
            self.orderCompleted(param: ["order_id" : objCurr.orderId])
        }
    }
    
    @IBAction func btnChatTapped(_ sender: UIButton){
        let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(identifier: "MessagesListVC") as! MessagesListVC
        if objBookingData != nil{
            if cellType == .currentCell {
                let obj = objBookingData!.arrCurrentBooked[sender.tag]
                chatVC.name = obj.users!.name
                chatVC.chatId = obj.chatId
            }else if cellType == .featureCell{
                let obj = objBookingData!.arrFeatureBooked[sender.tag]
                chatVC.name = obj.users!.name
                chatVC.chatId = obj.chatId
            }
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension BookingDetailsVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cellType{
        case .previousCell:
            if objBookingData != nil{
                if objBookingData!.arrPreviousBooked.isEmpty{
                    return 1
                }
                return objBookingData!.arrPreviousBooked.count
            }
            return 0
        case .currentCell:
            if objBookingData != nil{
                if arrFilterCurrentBooking.isEmpty{
                    return 1
                }
                return arrFilterCurrentBooking.count
            }
            return 0
        case .featureCell:
            if objBookingData != nil{
                if arrFilterFutureBooking.isEmpty{
                    return 1
                }
                return arrFilterFutureBooking.count
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BookingDetailsTblCell
        switch cellType{
        case .previousCell:
            if objBookingData != nil{
                if objBookingData!.arrPreviousBooked.isEmpty{
                    let cell : NoDataTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
                    cell.setText(str: "No bookings found")
                    return cell
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "previousCell", for: indexPath) as! BookingDetailsTblCell
                    cell.selectionStyle = .none
                    if let previousData = objBookingData{
                        let obj = previousData.arrPreviousBooked[indexPath.row]
                        cell.previousCell(previous: obj)
                    }
                    return cell
                }
            }
            
        case .currentCell:
            if objBookingData != nil{
                if arrFilterCurrentBooking.isEmpty{
                    let cell : NoDataTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
                    cell.setText(str: "No bookings found")
                    return cell
                }
                cell = tableView.dequeueReusableCell(withIdentifier: "currentFeaturesCell", for: indexPath) as! BookingDetailsTblCell
                cell.selectionStyle = .none
                let obj = arrFilterCurrentBooking[indexPath.row]
                cell.parent = self
                cell.currentCell(current: obj)
                cell.btnCancel.tag = indexPath.row
                cell.btnCompleted.tag = indexPath.row
                cell.btnChat.tag = indexPath.row
                return cell
            }
            
        case .featureCell:
            if objBookingData != nil{
                if arrFilterFutureBooking.isEmpty{
                    let cell : NoDataTableCell
                    cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
                    cell.setText(str: "No bookings found")
                    return cell
                }
                cell = tableView.dequeueReusableCell(withIdentifier: "currentFeaturesCell", for: indexPath) as! BookingDetailsTblCell
                cell.selectionStyle = .none
                let obj = arrFilterFutureBooking[indexPath.row]
                cell.parent = self
                cell.currentCell(current: obj)
                cell.btnChat.tag = indexPath.row
                cell.btnCancel.tag = indexPath.row
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let objData = objBookingData else {return}
        switch cellType{
        case .previousCell:
            if !objData.arrPreviousBooked.isEmpty{
                let previousData = objData.arrPreviousBooked[indexPath.row]
                self.performSegue(withIdentifier: "customerDetails", sender: previousData)
            }
        case .currentCell:
            if !arrFilterCurrentBooking.isEmpty{
                let currentData = arrFilterCurrentBooking[indexPath.row]
                self.performSegue(withIdentifier: "customerDetails", sender: currentData)
            }
        case .featureCell:
            if !arrFilterFutureBooking.isEmpty{
                let futureData = arrFilterFutureBooking[indexPath.row]
                self.performSegue(withIdentifier: "customerDetails", sender: futureData)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch cellType{
        case .previousCell:
            if objBookingData != nil{
                if objBookingData!.arrPreviousBooked.isEmpty{
                    return 100.widthRatio
                }
                return UITableView.automaticDimension
            }
        case .currentCell:
            if objBookingData != nil{
                if arrFilterCurrentBooking.isEmpty{
                    return 100.widthRatio
                }
                return UITableView.automaticDimension
            }
        case .featureCell:
            if objBookingData != nil{
                if arrFilterFutureBooking.isEmpty{
                    return 100.widthRatio
                }
                return UITableView.automaticDimension
            }
        }
        return 0
    }
}

//MARK:- Specified Reason
extension BookingDetailsVC{
    func prepareReasonView(index : Int, cellType : EnumBookingDetails){
        let vc = UIStoryboard(name: "BookingDetails", bundle: nil).instantiateViewController(identifier: "CancelReasonVC") as! CancelReasonVC
        vc.cellType = cellType
        if cellType == .currentCell{
            if objBookingData != nil{
                let obj = arrFilterCurrentBooking[index]
                vc.currentOrderId = obj.orderId
                if let user = obj.users{
                    vc.currentUserId = user.id
                }
            }
        } else if cellType == .featureCell{
            if objBookingData != nil{
                let obj = arrFilterFutureBooking[index]
                vc.futureOrderId = obj.orderId
                if let user = obj.users{
                    vc.futureUserId = user.id
                }
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK:- Get Bookings WebCall Methods
extension BookingDetailsVC{
    func getBookings(){
        showHud()
        KPWebCall.call.getBookings(param: [:]) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? NSDictionary{
                weakSelf.hideHud()
                weakSelf.objBookingData = nil
                //weakSelf.showSuccMsg(dict: dict)
                let dictData = BookingList(dict: result)
                weakSelf.objBookingData = dictData
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}


//MARK:- Order Completed WebCall Methods
extension BookingDetailsVC{
    func orderCompleted(param : [String : Any]){
        showHud()
        KPWebCall.call.orderCompletedByDriver(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200,let dict = json as? NSDictionary{
                //weakSelf.showSuccMsg(dict: dict)
                weakSelf.showAlert(title: "Success", msg: "Order Completed Successfully.")
                weakSelf.getBookings()
                weakSelf.tableView.reloadData()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Alert
extension BookingDetailsVC{
    func showAlert(title : String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- Date&Time Methods
extension BookingDetailsVC{
    func getTodayDate() -> String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    func getSubStringTime(time : String) -> String{
        let subStr = time.prefix(5)
        return String(subStr)
    }
    
    func getTimeDifferentFormate() -> String{
        let date = Date()
        let getTime = date.getTime()
        return "\(getTime.hour)" + ":" + "\(getTime.minute)"
    }
}
