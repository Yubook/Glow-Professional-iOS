//
//  BarberTermsPrivacyVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 10/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class BarberTermsPrivacyVC: ParentViewController {
    @IBOutlet weak var lblPlaceHolder : UILabel!
    @IBOutlet weak var txtViewterms : UITextView!
    @IBOutlet weak var btnOk : UIButton!
    var privacyContant = ""
    var objContent : Terms?

    override func viewDidLoad() {
        super.viewDidLoad()
        getDriverData()
    }
}

//MARK:- Others Methods
extension BarberTermsPrivacyVC{
    
    func paramUpdateTerms() -> [String:Any]{
        var dict : [String:Any] = [:]
        dict["id"] = objContent!.id
        dict["type"] = objContent!.type
        dict["content"] =  objContent!.content
        return dict
    }
    
    @IBAction func btnAddEditTapped(_ sender: UIButton){
        if objContent  != nil{
            self.addUpdateTerms(param: paramUpdateTerms())
        }
    }
}

//MARK:- TextView Delegate Methods
extension BarberTermsPrivacyVC : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !txtViewterms.text.isEmpty ? true : false
        if objContent != nil{
            objContent!.content = txtViewterms.text
        }
    }
}


//MARK:- Get Driver Profile Methods
extension BarberTermsPrivacyVC {
    func getDriverData(){
        showHud()
        KPWebCall.call.getDriverData(param: ["barber_id" : _user.id]) {[weak self] (json, statusCode) in
            guard let weakSelf = self,let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                if let dictResult = dict["result"] as? NSDictionary{
                    if let privacy = dictResult["policy_and_term"] as? NSDictionary{
                        let objData = Terms(dict: privacy)
                        weakSelf.txtViewterms.text = objData.content
                        weakSelf.lblPlaceHolder.isHidden = objData.content == "" ? false : true
                        weakSelf.objContent = objData
                    }
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Update Terms and Condition Web Call Methods
extension BarberTermsPrivacyVC{
    func addUpdateTerms(param: [String:Any]){
        showHud()
        KPWebCall.call.updateTerms(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                weakSelf.showSuccMsg(dict: dict) {
                    weakSelf.navigationController?.popViewController(animated: true)
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
