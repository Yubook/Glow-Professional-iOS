//
//  SelectServicesVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class SelectServicesVC: ParentViewController {
    @IBOutlet weak var btnDismiss : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnContinue : UIButton!
    
    
    var arrServices : [Services] = []
    var paramDictData : [String:Any] = [:]
    var isEdit = false
    var arrAddedService : [SelectedServices] = []
    var textField = UITextField()
    var isDeleted = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = isEdit ? "Edit Services" : "Select Your Services"
        btnContinue.setTitle(isEdit ? "Edit Services" : "Continue", for: .normal)
        if isEdit{
            getSelectedService()
        }else{
            getService()
        }
        prepareUI()
    }
}

//MARK:- Others Methods
extension SelectServicesVC{
    func prepareUI(){
        btnDismiss.isHidden = isEdit ? false : true
        let selectedServices = arrServices.filter{$0.isSelected}
        btnContinue.isEnabled = selectedServices.isEmpty ? false : true
        btnContinue.backgroundColor = selectedServices.isEmpty ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        getNoDataCell()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    func paramDictArray(selectedData: [Services]) -> [String: Any]{
        var arrDict : [String:Any] = [:]
        for (idx,data) in selectedData.enumerated(){
            arrDict["service_id[" + "\(idx)" + "]"] = Int(data.id)!
            arrDict["price[" + "\(idx)" + "]"] = Double(data.price)!
        }
        return arrDict
    }
    
    @IBAction func btnContinueTapped(_ sender: UIButton){
        let selectedData = self.arrServices.filter{$0.isSelected}
        let dict = paramDictArray(selectedData: selectedData)
        if !selectedData.isEmpty{
            self.updatePrice(param: dict)
        }else{
            self.showError(msg: kSelectedServices)
        }
    }
    
    @IBAction func btnDeleteService(_ sender: UIButton){
        let objData = arrServices[sender.tag]
        self.deleteService(param: ["id" : objData.editServiceId]) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? SelectServicesTblCell{
                cell.btnDelete.isHidden = true
                cell.trailingConstraint.constant = 15
                cell.tfPriceInput.text = ""
                objData.price = ""
            }
            objData.isServiceAdded = false
            self.isDeleted = true
            //self.tableView.reloadData()
        }
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension SelectServicesVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrServices.isEmpty{
            return 1
        }
        return arrServices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrServices.isEmpty{
            let cell : NoDataTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
            cell.setText(str: "No Servies Found")
            return cell
        }
        let cell : SelectServicesTblCell
        let objData = arrServices[indexPath.row]
        cell = tableView.dequeueReusableCell(withIdentifier: "selectServiceCell", for: indexPath) as! SelectServicesTblCell
        cell.parentVC = self
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.isHidden = isEdit ? false : true
        cell.trailingConstraint.constant = isEdit ? 70 : 15
        textField = cell.tfPriceInput
        cell.selectionStyle = .none
        cell.prepareServiceUI(data: objData, indx: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrServices.isEmpty{
            return 100.widthRatio
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData = arrServices[indexPath.row]
        /*if isEdit{
            objData.isServiceAdded.toggle()
        }*/
        objData.isSelected.toggle()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        let selectedServices = arrServices.filter{$0.isSelected}
        btnContinue.isEnabled = selectedServices.isEmpty ? false : true
        btnContinue.backgroundColor = selectedServices.isEmpty ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

//MARK:- Get Services WebCall Methods
extension SelectServicesVC{
    func getService(){
        showHud()
        KPWebCall.call.getServices(param: [:]) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                //weakSelf.showSuccMsg(dict: dict)
                if let arrResult = dict["result"] as? [NSDictionary]{
                    for dictRes in arrResult{
                        let objData = Services(dict: dictRes)
                        weakSelf.arrServices.append(objData)
                    }
                }
                weakSelf.tableView.reloadData()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Update Price WebCall Methods
extension SelectServicesVC{
    func updatePrice(param: [String:Any]){
        showHud()
        KPWebCall.call.addServices(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.showSuccMsg(dict: dict) {
                    _user.isServiceAdded = true
                    _appDelegator.saveContext()
                    _appDelegator.navigateUserToHome()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
    
    func getSelectedService(){
        showHud()
        KPWebCall.call.getAddedServices {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                //weakSelf.showToast(data: dict)
                weakSelf.showSuccMsg(dict: dict)
                weakSelf.hideHud()
                if let arrSelectedServices = dict["result"] as? [NSDictionary]{
                    for dictService in arrSelectedServices{
                        let objData = Services(dict: dictService)
                        objData.isServiceAdded.toggle()
                        weakSelf.arrServices.append(objData)
                    }
                    weakSelf.tableView.reloadData()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
                //weakSelf.showToast(data: json)
            }
        }
    }
}

//MARK:- Delete Service Methods
extension SelectServicesVC{
    func deleteService(param: [String:Any],completion : (() -> ())?){
        showHud()
        KPWebCall.call.deleteServices(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                weakSelf.showSuccMsg(dict: dict, completion: completion)
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
