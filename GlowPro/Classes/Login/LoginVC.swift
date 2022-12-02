//
//  LoginVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/8/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import FittedSheets

class LoginVC: ParentViewController {
    let objData = Login()
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
}

//MARK: - Others Methods
extension LoginVC{
    func prepareUI(){
        objData.prepareData()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
    }
    
    @IBAction func btnLoginRegisterTapped(_ sender: UIButton){
        let countryCode = _userDefault.value(forKey: "countryCode")
        if String.validateStringValue(str:countryCode as? String  ?? "") {
            showError(msg: "Please select country code")
            return
        }
        
        let validate = objData.validatetData()
        if validate.isValid {
            //checkUserExist()
            let number = objData.arrData[1].value
            self.performSegue(withIdentifier: "otp", sender: number)
        } else {
            showError(msg: validate.error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otp"{
            if let vc = segue.destination as? OtpVC{
                if let data = sender as? String{
                    vc.phone = data
                    var countryCode = _userDefault.value(forKey: "countryCode") as? String ?? ""
                    if countryCode == "" {
                        countryCode = "+44"
                    }
                    vc.userPhone = "\(countryCode)\(data)"
                }
            }else{
                print("OTPVC not Found")
            }
        }
    }
}

//MARK: - TableView Delegate & DataSource Methods
extension LoginVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objData.arrData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : LoginTblCell
        
        let objLoginData = objData.arrData[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: objLoginData.cellType.cellId, for: indexPath) as! LoginTblCell
        cell.parentVC = self
        cell.prepareCell(data: objLoginData, index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return objData.arrData[indexPath.row].cellType.cellHeight
    }
}
