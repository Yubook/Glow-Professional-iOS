//
//  RegisterVC.swift
//  GlowPro
//
//  Created by MutipzTechnology on 30/03/22.
//  Copyright © 2022 Devang Lakhani. All rights reserved.
//

import UIKit
import SwiftUI
import CoreLocation

class RegisterVC: ParentViewController {
    //MARK: - Variables & Outlets
    @IBOutlet weak var imgUser : UIImageView!
    var profileImg : UIImage!
    var objRegisterData = Register()
    var phoneNumber = ""
    var isMainProfile = false
    var addressImg : UIImage!
    var proofIdImg : UIImage!
    var index = 0
    var arrState : [State] = []
    var arrCity : [City] = []
    var proofId = ""
    var address = ""
    var arrKeys : [String] = []
    var arrImgs: [UIImage] = []
    
    //MARK: - ViewController LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

//MARK: - Others Methods
extension RegisterVC{
    func prepareUI(){
        objRegisterData.prepareData()
        getStateData()
        getCityData()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    @IBAction func btnAddProfilePicTapped(_ sender: UIButton){
        let pickerVC = UIImagePickerController()
        self.prepareImagePicker(pictureController: pickerVC)
        pickerVC.delegate = self
    }
    
    @IBAction func btnSubmitTapped(_ sender: UIButton){
        self.showHud()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.registerUser()
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - TableView Delegate & DataSource Methods
extension RegisterVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objRegisterData.arrData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objData = objRegisterData.arrData[indexPath.row]
        let cell : RegisterTblCell
        cell = tableView.dequeueReusableCell(withIdentifier: objData.cellType.cellId, for: indexPath) as! RegisterTblCell
        cell.parentRegister = self
        cell.configCellData(data: objData, idx: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return objRegisterData.arrData[indexPath.row].cellType.cellHegiht
    }
}

//MARK: - ImagePicker Methods
extension RegisterVC{
    func prepareImagePicker(pictureController : UIImagePickerController){
        let actionSheet = UIAlertController(title: "SelectType", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            pictureController.sourceType = .camera
            pictureController.cameraCaptureMode = .photo
            pictureController.allowsEditing = true
            self.present(pictureController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "PhotoLibrery", style: .default, handler: { _ in
            pictureController.sourceType = .photoLibrary
            pictureController.allowsEditing = true
            self.present(pictureController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}


//MARK: - UIImagePickerDelegate Methods
extension RegisterVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            imgUser.contentMode = .scaleAspectFit
            profileImg = image
            imgUser.image = profileImg == nil ? UIImage(named: "ic_placeholder") : image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Get State & City Web Call Methods
extension RegisterVC{
    func getStateData(){
        showHud()
        KPWebCall.call.getState {[weak self] json, statusCode in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200, let res = dict["result"] as? [NSDictionary]{
                weakSelf.hideHud()
                for objState in res{
                    let objData = State(dict: objState)
                    weakSelf.arrState.append(objData)
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
    
    func getCityData(){
        showHud()
        KPWebCall.call.getCities {[weak self] json, statusCode in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200, let res = dict["result"] as? [NSDictionary]{
                weakSelf.hideHud()
                for objState in res{
                    let objData = City(dict: objState)
                    weakSelf.arrCity.append(objData)
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}


//MARK: - Register User WebCall Methods
extension RegisterVC{
    func paramRegisterDict() -> [String:Any]{
        var dict : [String:Any] = [:]
    
        if objRegisterData.arrData[0].placeHolderName == "Barber Name *" {
            dict["name"] = objRegisterData.arrData[0].value
        }
        
        if objRegisterData.arrData[1].placeHolderName == "Address Line 1 *" {
            dict["address_line_1"] = objRegisterData.arrData[1].value
        }
        
        if objRegisterData.arrData[2].placeHolderName == "Address Line 2" {
            dict["address_line_2"] = objRegisterData.arrData[2].value
        }
        
       
        if objRegisterData.arrData[3].placeHolderName == "Postcode" {
            dict["latitude"] = "\(23.0309959)"
            dict["longitude"] = "\(72.6343223)"
            self.getLatlong(postCode: objRegisterData.arrData[3].value) { lat, long in
                dict["latitude"] = "\(lat)"
                dict["longitude"] = "\(long)"
            }
        }
        
        if objRegisterData.arrData[4].dropDownPlaceholder == "City *" {
            dict["city"] = "\(objRegisterData.arrData[4].dropDownId)"
        }
        if objRegisterData.arrData[5].placeHolderName == "Email" {
            dict["email"] = objRegisterData.arrData[5].value
        }
        if objRegisterData.arrData[6].placeHolderName == "PhoneNo" {
            dict["mobile"] = phoneNumber
        }
        if objRegisterData.arrData[7].placeHolderName == "Gender" {
            dict["gender"] = objRegisterData.arrData[7].value
        }
        
        dict["document_1_name"] = "proofId"
        dict["document_2_name"] = "address"
//        dict["state"] = "\(objRegisterData.arrData[9].dropDownId)"
        let countryID = _userDefault.value(forKey: "countryID")
        dict["country_id"] = "\(countryID!)"
        
        if profileImg != nil {
            self.arrKeys.append("profile")
            self.arrImgs.append(profileImg)
        }

        if proofIdImg != nil {
            self.arrKeys.append("document_1")
            self.arrImgs.append(proofIdImg)
        }
        
        if addressImg != nil {
            self.arrKeys.append("document_2")
            self.arrImgs.append(addressImg)
        }
        let countryCode = _userDefault.value(forKey: "countryCode")
        dict["phone_code"] = countryCode
        return dict
    }
    
    func getLatlong(postCode: String, completion: @escaping ((Double,Double) -> ())){
        let geocoder = CLGeocoder()
        let dic = [NSTextCheckingKey.zip: postCode]
        geocoder.geocodeAddressDictionary(dic) { (placemark, error) in
            if error == nil{
                if let placemark = placemark?.first {
                    let lat = placemark.location!.coordinate.latitude
                    let long = placemark.location!.coordinate.longitude
                    completion(lat,long)
                }
            }
        }
    }
    
    func registerUser(){
        showHud()
        KPWebCall.call.addBarberProfile(param: paramRegisterDict(), imgs: arrImgs, keys: arrKeys) {[weak self] json, statusCode in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                weakSelf.showSuccMsg(dict: dict, completion: nil)
                _appDelegator.navigateUserToHome()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
