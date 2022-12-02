//
//  ProfileVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/8/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI

class ProfileVC: ParentViewController {
    @IBOutlet weak var imgProfileView : UIImageView!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var notiView : UIView!
    
    var isAvailable = false
    var arrProfileData : [ProfileDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notiView.isHidden = _userDefault.integer(forKey: "isNotificationRead") == 0 ? true : false
        setProfile()
    }
}

//MARK:- Others Methods
extension ProfileVC{
    func prepareUI(){
        prepareData()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: _tabBarHeight + 10, right: 0)
    }
    
    @IBAction func btnNotificationTapped(_ sender: UIButton){
        self.performSegue(withIdentifier: "notificationList", sender: nil)
    }
    
    @IBAction func btnEditProfileTapped(_ sender: UIButton){
        self.performSegue(withIdentifier: "profileSetup", sender: nil)
    }
    
    @IBAction func availableBarberChanged(_ sender: UISwitch){
        if sender.isOn{
            isAvailable = true
            sender.setOn(true, animated: true)
        }else{
            isAvailable = false
            sender.setOn(false, animated: true)
        }
        _userDefault.set(isAvailable, forKey: "availablity")
        self.availableBarber()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSetup"{
            let vc = segue.destination as! EditProfileVC
            vc.isEdit = true
        }
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension ProfileVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProfileData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ProfileTblCell
        cell = tableView.dequeueReusableCell(withIdentifier: "featureCell", for: indexPath) as! ProfileTblCell
        cell.selectionStyle = .none
        cell.prepareCell(data: arrProfileData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            self.performSegue(withIdentifier: "insight", sender: nil)
        case 1:
            self.shareApp()
        case 2:
            self.performSegue(withIdentifier: "paymentHistory", sender: nil)
        case 3:
            self.performSegue(withIdentifier: "barberTerms", sender: nil)
        case 6:
            let vc = UIStoryboard(name: "Entry", bundle: nil).instantiateViewController(identifier: "SelectServicesVC") as! SelectServicesVC
            vc.isEdit = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 9:
            UIAlertController.actionWith(title: "Sign Out?", message: "Are you sure you want to sign out?", style: .actionSheet, buttons: [kCancel,kYes], controller: self) { (action) in
                if action == kYes {
                    self.logOutUser()
                }
            }
        case 8:
            let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(identifier: "MessagesListVC") as! MessagesListVC
            chatVC.name = "Customer Support"
            chatVC.chatId = "\(_userDefault.integer(forKey: "adminChatId"))"
            self.navigationController?.pushViewController(chatVC, animated: true)
        case 7:
            let vc = UIStoryboard(name: "Entry", bundle: nil).instantiateViewController(identifier: "RadiusVC") as! RadiusVC
            vc.isEdit = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 5:
            self.performSegue(withIdentifier: "showCase", sender: nil)
            
        default : break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.widthRatio
    }
}

//MARK:- Prepare Data
extension ProfileVC{
    func prepareData(){
        var arrData : [ProfileDetails] = []
        arrData.append(contentsOf: [ProfileDetails(iconName: "ic_insight", featureName: "Revenue"),
                                    ProfileDetails(iconName: "ic_invite_friends", featureName: "Invite Friends"),
                                    ProfileDetails(iconName: "ic_payment_history", featureName: "Payment History"),
                                    ProfileDetails(iconName: "ic_terms_conditon", featureName: "Your Terms & Conditions"),
                                    ProfileDetails(iconName: "ic_Avaible", featureName: "Availability"),
                                    ProfileDetails(iconName: "ic_addPortfolio_n", featureName: "ShowCase"),
                                    ProfileDetails(iconName: "ic_editService", featureName: "Edit Services"),
                                    ProfileDetails(iconName: "ic_edit_radius", featureName: "Edit Radius"),
                                    ProfileDetails(iconName: "ic_customer_support", featureName: "Customer Support"),
                                    ProfileDetails(iconName: "ic_logOut", featureName: "Log Out")])
        self.arrProfileData.append(contentsOf: arrData)
    }
}

//MARK:- Set Driver Details
extension ProfileVC{
    func setProfile(){
        if self.tabBarController != nil{
            let tabBar = self.tabBarController as! JTabBarController
            tabBar.tabBarView.imgView.kf.setImage(with: _user.profileUrl)
        }
        lblUserName.text = _user.name
        lblEmailId.text = _user.email
        imgProfileView.kf.setImage(with: _user.profileUrl)
    }
}

//MARK:- LogOut WebCall Methods
extension ProfileVC{
    func logOutUser(){
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
            exitUser()
        }catch let err as NSError{
            showError(msg: err.localizedDescription)
        }
    }
    
    func exitUser(){
        showHud()
        KPWebCall.call.logOutUser {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200{
                _appDelegator.removeUserInfoAndNavToLogin()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}


//MARK:- Barber Available Methods
extension ProfileVC{
    func availableBarber(){
        showHud()
        KPWebCall.call.barberAvailblity(param: ["status" : isAvailable]) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                //weakSelf.showSuccMsg(dict: dict)
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Invite Friends Methods
extension ProfileVC{
    
    func shareApp(){
        let otherName = "Fade Barber App \nGet the best deal to book your appointment with fade. \nInstall App Now \nDownload Android App \n" + "\(URL(string: "https://developer.apple.com/swift/")!)" + "\nDownload iOS App \n" + "\(URL(string: "https://developer.apple.com/swift/")!)"
        let objectsToShare = [otherName]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}
