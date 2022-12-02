//
//  PaymentHistoryVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/13/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class PaymentHistoryVC: ParentViewController {
    
    @IBOutlet weak var lblTotalExpence : UILabel!
    var arrPaymentHistory : [Orders] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrders()
        prepareUI()
    }
}

//MARK:- Others Methods
extension PaymentHistoryVC{
    func prepareUI(){
        getNoDataCell()
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension PaymentHistoryVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrPaymentHistory.isEmpty{
            return 1
        }
        return arrPaymentHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrPaymentHistory.isEmpty{
            let cell : NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
            cell.setText(str: "No Payment History Available")
            return cell
        }
        let cell : PaymentHistoryTblCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! PaymentHistoryTblCell
        cell.preparePaymnetCell(data: arrPaymentHistory[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrPaymentHistory.isEmpty{
            return 100.widthRatio
        }
        return 75.widthRatio
    }
}


//MARK:- Payment History WebCall Methods
extension PaymentHistoryVC{
    func getOrders(){
        showHud()
        KPWebCall.call.getOrders(param: [:]) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? NSDictionary{
                if let totalExpance = result["totalExpense"] as? Int{
                    weakSelf.lblTotalExpence.text = "£ " + "\(totalExpance)"
                }
                if let orderData = result["order"] as? NSDictionary{
                    if let arrOrder = orderData["data"] as? [NSDictionary]{
                        for dictData in arrOrder{
                            let objOrder = Orders(dict: dictData)
                            if objOrder.isOrderCompleted == 1 || objOrder.isOrderCompleted == 2{
                                weakSelf.arrPaymentHistory.append(objOrder)
                            }
                        }
                    }
                }
                weakSelf.tableView.reloadData()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
