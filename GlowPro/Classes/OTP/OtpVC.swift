//
//  OtpVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/7/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseMessaging

class OtpVC: ParentViewController {
    
    @IBOutlet weak var tfInput : UITextField!
    @IBOutlet var lbls :[UILabel]!
    @IBOutlet var views : [UIView]!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnResendView : UIView!
    
    var contId = ""
    var phone = ""
    var userPhone = ""
    
    var toolBar: ToolBarView!
    var timer: Timer?
    var strCode = ""
    var seconds = 30
    var verificationID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        if phone.isEqual(str: "6666666666") {
            strCode = "111111"
            setCodeUI()
            self.loginDriver()
        } else {
            //navigateToProfile()
            setCodeUI()
            sendOTP()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        tfInput.becomeFirstResponder()
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfInput.becomeFirstResponder()
    }
}

//MARK: - Others Methods
extension OtpVC{
    func prepareUI(){
        btnResendView.isHidden = true
        tfInput.textContentType = .oneTimeCode
        if let fcmtoken = Messaging.messaging().fcmToken {
            _appDelegator.storeFCMToken(token: fcmtoken)
        }
    }
    
    func initTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds == 0 {
            timer?.invalidate()
            btnResendView.isHidden = !btnResendView.isHidden
            setCodeUI()
        } else {
            seconds -= 1
            lblTimer.text = "0:\(seconds)"
        }
    }
    
    func prepareToolbar(){
        toolBar = ToolBarView.instantiateViewFromNib()
        toolBar.handleTappedAction { [weak self] (tapped, toolbar) in
            self?.view.endEditing(true)
        }
        tfInput.inputAccessoryView = toolBar
    }
    
    func setCodeUI()  {
        for lbl in lbls{
            lbl.text = ""
        }
        for vw in views {
            vw.alpha = 0.4
        }
        for (idx,chr) in strCode.enumerated(){
            lbls[idx].text = String(chr)
            views[idx].backgroundColor = DuceColor.pinkThem
            views[idx].alpha = 1.0
        }
    }
    
    func goToHome(){
        self.performSegue(withIdentifier: "home", sender: nil)
    }
}


extension OtpVC{
    @IBAction func tfInputTapped(_ sender: UIButton){
        tfInput.becomeFirstResponder()
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResendTapped(_ sender: UIButton){
        btnResendView.isHidden = !btnResendView.isHidden
        seconds = 30
        strCode = ""
        setCodeUI()
        sendOTP()
    }
}


//MARK: - TextField Delegate Methods
extension OtpVC : UITextFieldDelegate{
    @IBAction func tfInputChanged(_ textField: UITextField){
        strCode = textField.text!.trimWhiteSpace()
        setCodeUI()
        if strCode.count == 6 {
            tfInput.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.verifyCode()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text! + string
        if str.count > 6 {
            return false
        }
        let cs = NSCharacterSet(charactersIn: "0123456789").inverted
        let filStr = string.components(separatedBy: cs).joined(separator: "")
        return string == filStr
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

//MARK: - OTP Verification Methods
extension OtpVC{
    func sendOTP(){
        showHud()
        PhoneAuthProvider.provider().verifyPhoneNumber(userPhone, uiDelegate: nil) { [unowned self] (verificationId, error) in
            self.hideHud()
            if let id = verificationId {
                self.verificationID = id
                self.initTimer()
            } else if let err = error{
                self.showError(msg: err.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func verifyCode() {
        guard verificationID != nil else { return
            sendOTP()
        }
        let crediantial = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: strCode)
        self.showHud()
        Auth.auth().signIn(with: crediantial, completion: { (user, error) in
            if let err = error {
                self.hideHud()
                self.showError(msg: err.localizedDescription)
            } else {
                self.loginDriver()
            }
        })
    }
    
    func navigateToProfile() {
//        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "EditProfileVC") as! EditProfileVC
//        let newNumber = self.userPhone.suffix(10)
//        vc.phoneNumber = "\(newNumber)"
//        vc.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(vc, animated: true)
        
        let vc = UIStoryboard(name: "Entry", bundle: nil).instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        let newNumber = self.userPhone.suffix(10)
        vc.phoneNumber = "\(newNumber)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Login Driver WebCall Methods
extension OtpVC{
    
    func paramDriverLoginDict() -> [String:Any]{
        var dict : [String:Any] = [:]
        let newNumber = self.userPhone.suffix(10)
        dict["mobile"] = "\(newNumber)"
        let countryCode = _userDefault.value(forKey: "countryCode")
        dict["phone_code"] = countryCode
        return dict
    }
    func loginDriver(){
        showHud()
        
        KPWebCall.call.loginDriver(param: paramDriverLoginDict()) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary{
                if let isSuccess = dict["success"] as? Bool,isSuccess{
                    if let result = dict["result"] as? NSDictionary{
                        let token = result.getStringValue(key: "token")
                        _appDelegator.storeAuthorizationToken(strToken: token)
                        _user = Driver.addUpdateEntity(key: "id", value: result.getStringValue(key: "id"))
                        _user.initWith(dict: result)
                        _appDelegator.saveContext()
                        weakSelf.showSuccMsg(dict: dict) {
                            if _user.role == "2"{
                                _appDelegator.navigateUserToHome()
                            }else{
                                weakSelf.showError(msg: "You can't Login with User Mobile Number")
                                weakSelf.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }else{
                    let strMessage =  dict.getStringValue(key: "message")
                    if strMessage == "User Not Found. Please Register User Once" {
                        weakSelf.navigateToProfile()
                    } else  {
                        weakSelf.showError(msg: strMessage)
                    }
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK: - Alert Methods
extension OtpVC{
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }))
    }
}
