//
//  CancelReasonVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class CancelReasonVC: ParentViewController {
    var arrReasons : [CancelReason] = []
    var otherReason : String = ""
    var selctedImgView : UIImageView?
    var isOtherSelected : Bool = false
    var isAlreadySelected : Bool = false
    var futureOrderId : String = ""
    var futureUserId : String = ""
    var currentOrderId : String = ""
    var currentUserId : String = ""
    var reasonMsg : String = ""
    var cellType : EnumBookingDetails!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReasons()
        prepareUI()
    }
    
}

//MARK:- Others Methods
extension CancelReasonVC{
    func prepareUI(){
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
        tableView.separatorStyle = .none
    }
    
    @IBAction func btnSubmitTapped(_ sender: UIButton){
        if String.validateStringValue(str: reasonMsg){
            self.showError(msg: "Please Select Valid Reason")
        }else{
            self.cancelOrder()
        }
    }
    
    func selectedCell(index : Int){
        for (idx,reason) in arrReasons.enumerated(){
            if idx == index{
                reasonMsg = reason.reasonName
                reason.isSelected = true
                if reason.reasonName == "Other"{
                    isOtherSelected = true
                }else{
                    isOtherSelected = false
                }
            }else{
                reason.isSelected = false
            }
        }
        self.tableView.reloadData()
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension CancelReasonVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return arrReasons.count
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CancelReasonTblCell
        
        if indexPath.section == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath) as! CancelReasonTblCell
            cell.parent = self
            cell.prepareCell(data: arrReasons[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath) as! CancelReasonTblCell
            cell.selectionStyle = .none
            cell.parent = self
            cell.prepareTextView()
            cell.prepareOtherCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let obj = arrReasons[indexPath.row]
            if obj.isSelected{isOtherSelected = false}
            self.selectedCell(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 50.widthRatio
        }else{
            return UITableView.automaticDimension
        }
    }
}
//MARK:- CancelReason WebCall Methods
extension CancelReasonVC{
    func getReasons(){
        showHud()
        KPWebCall.call.getCancelReason {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? [NSDictionary]{
                weakSelf.showToast(data: dict)
                for dictData in result{
                    let reasonData = CancelReason(dict: dictData)
                    weakSelf.arrReasons.append(reasonData)
                }
                weakSelf.arrReasons.append(CancelReason(dict: ["id" : 5, "reason" : "Other"]))
                weakSelf.tableView.reloadData()
            }else{
                weakSelf.showToast(data: json)
            }
        }
    }
}

//MARK:- CancelBooking WebCall Methods
extension CancelReasonVC{
    func paramDict() -> [String: Any]{
        var dict : [String: Any] = [:]
        dict["user_id"] = cellType == .currentCell ? currentUserId : futureUserId
        dict["order_id"] = cellType == .currentCell ? currentOrderId : futureOrderId
        dict["barber_id"] = _user.id
        dict["cancle_by"] = "barber"
        dict["reason"] = reasonMsg
        return dict
    }
    
    func cancelOrder(){
        showHud()
        KPWebCall.call.cancelOrder(param: paramDict()) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary{
                weakSelf.showSuccMsg(dict: dict)
                weakSelf.dismiss(animated: true, completion: nil)
                weakSelf.showPopup(title: "Success", msg: "Order is Cancel Successfully")
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
                
            }
        }
    }
}
