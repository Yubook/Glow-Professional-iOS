//
//  EditProfileVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/14/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class EditProfileVC: ParentViewController {
    @IBOutlet weak var imgProfileView : UIImageView!
    @IBOutlet weak var btnDismiss : UIButton!
    @IBOutlet weak var frontView : UIView!
    @IBOutlet weak var imgPlaceholder : UIImageView!
    
    var profileImage : UIImage!
    var objModel = EditProfile()
    var phoneNumber : String = ""
    var userLocation: CLLocation?
    var latitude : Double = 0.00
    var longitude : Double = 0.00
    var txtFieldText : String = ""
    var isEdit : Bool = false
    var selectedAddress: SearchAddress!
    var isGenderSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

//MARK:- Others Methods
extension EditProfileVC{
    func prepareUI(){
        frontView.isHidden = isEdit ? false : true
        imgPlaceholder.isHidden = isEdit ? false : true
        btnDismiss.isHidden = isEdit ? false : true
        objModel.prepareData()
        setSavedUserData()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func getData(completion: @escaping (UIImage?) -> ()) {
        guard let url = _user.profileUrl else {return}
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                let img = UIImage(data: data)
                completion(img)
            }
        }.resume()
    }
    
   /* func prepareHexaView(){
        let maskPath = UIBezierPath(square: hexaView.bounds, numberOfSides: 6, cornerRadius: 8.0)
        
        let maskingLayer = CAShapeLayer()
        maskingLayer.path = maskPath?.cgPath
        
        maskingLayer.lineWidth = 4.0
        maskingLayer.strokeColor = UIColor.white.cgColor
        maskingLayer.fillColor = UIColor.clear.cgColor
        maskingLayer.frame = hexaView.bounds
        hexaView.layer.addSublayer(maskingLayer)
    } */
    
    @IBAction func btnAddressTapped(_ sender: UIButton){
        getUserCurrLocation()
        self.getAddressLocation()
    }
    
    @IBAction func btnAddProfileTapped(_ sender : UIButton){
        let pic = UIImagePickerController()
        self.prepareImagePicker(pictureController: pic)
        pic.delegate = self
    }
    
    @IBAction func btnSaveProfileTapped(_ sender: UIButton){
        let validate = objModel.validateData()
        let validOtherData = validateImage()
        
        if validate.isValid && validOtherData.isValid{
            isEdit ? self.editProfile() : self.registerDriver()
        }else{
            showError(msg: validOtherData.error)
            showError(msg: validate.error)
        }
    }
    
    func validateImage() -> (isValid: Bool, error : String){
        var res = (isValid : true, error : "")
        
        if String.validateStringValue(str: txtFieldText){
            res.isValid = false
            res.error = kEnterLocation
        }else if profileImage == nil{
            res.isValid = false
            res.error = kSelectProfilePicture
        }
        
        return res
    }
    
    func setSavedUserData(){
        if isEdit{
            getData { (image) in
                self.imgProfileView.contentMode = .scaleAspectFill
                self.imgProfileView.image = image
                self.profileImage = image
                self.frontView.isHidden = self.profileImage == nil ? false : true
                self.imgPlaceholder.isHidden = self.profileImage == nil ? false : true
            }
        }
        if _user != nil{
            self.txtFieldText = _user.address
            self.phoneNumber = _user.mobile
            self.latitude = Double(_user.latitude) ?? 0.0
            self.longitude = Double(_user.longitude) ?? 0.0
        }
        
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension EditProfileVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objModel.arrEditProfileData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EditProfileTblCell
        let objData = objModel.arrEditProfileData[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: objData.cellType.cellId, for: indexPath) as! EditProfileTblCell
        cell.parentVC = self
        cell.prepareCell(data: objData, index: indexPath.row)
        
        if isEdit {
            cell.disableText(data: objData, index: indexPath.row)
        }
        if objData.cellType == .phoneCell{
            cell.isUserInteractionEnabled = false
            cell.alpha = 0.5
            cell.tfInputPhone.isUserInteractionEnabled = false
            cell.tfInputPhone.alpha = 0.5
            cell.tfInputPhone.text = phoneNumber
        }else if objData.cellType == .locationCell{
            if txtFieldText == ""{
                cell.tfInputLocation.placeholder = "Adresss"
            }else{
                cell.tfInputLocation.text = txtFieldText
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return objModel.arrEditProfileData[indexPath.row].cellType.cellHeight
    }
}


//MARK:- ImagePicker Methods
extension EditProfileVC{
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


//MARK:- UIImagePickerDelegate Methods
extension EditProfileVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            imgProfileView.contentMode = .scaleAspectFit
            imgProfileView.image = image
            profileImage = image
            frontView.isHidden = profileImage == nil ? false : true
            imgPlaceholder.isHidden = profileImage == nil ? false : true
            self.dismiss(animated: true, completion: nil)
        }
       /* if picker.sourceType == .camera{
            if let image = info[.originalImage] as? UIImage{
                imgProfileView.contentMode = .scaleAspectFill
                imgProfileView.image = image
                profileImage = image
                self.dismiss(animated: true, completion: nil)
            }
        }else if picker.sourceType == .photoLibrary{
            if let image = info[.editedImage] as? UIImage{
                imgProfileView.contentMode = .scaleAspectFit
                imgProfileView.image = image
                profileImage = image
                self.dismiss(animated: true, completion: nil)
            }
        }*/
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Open MAP
extension EditProfileVC{
    
    func getUserCurrLocation() {
        weak var controller: UIViewController! = self
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
            if let _ = location {
                let lattitude = location!.coordinate.latitude
                let longitude = location!.coordinate.longitude
                self.userLocation = CLLocation(latitude: lattitude, longitude: longitude)
                if let location = self.userLocation {
                    self.getAddressFromLocation(location: location)
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getAddressFromLocation(location: CLLocation) {
        KPAPICalls.shared.addressFromlocation(location: location) { (address) in
            if let address = address{
               print(address)
            }
        }
    }
    
    func getAddressLocation() {
        self.view.endEditing(true)
        let mapVC = UIStoryboard(name: "KPLocation", bundle: nil).instantiateViewController(withIdentifier: "KPMapVC") as! KPMapVC
        mapVC.callBackBlock = {[weak self] address in
            guard let weakSelf = self else {return}
            weakSelf.userLocation = address.location
            weakSelf.latitude = address.lat
            weakSelf.longitude = address.long
            if address.name != nil{
                weakSelf.txtFieldText = address.name + ", " + address.city
            }else{
                weakSelf.txtFieldText = address.formatedAddress + "," + address.city + "," + address.state + "," + address.country
            }
            weakSelf.selectedAddress = address
            weakSelf.tableView.reloadData()
        }
        
        self.present(mapVC, animated: true, completion: nil)
    }
}

//MARK:- Register Profile WebCall Methods
extension EditProfileVC{
    func paramDict() -> [String : Any]{
        var dict : [String : Any] = [:]
        dict["role_id"] = "2"
        dict["address"] = txtFieldText
      //  dict["mobile"] = phoneNumber
        dict["latitude"] = "\(latitude)"
        dict["longitude"] = "\(longitude)"
        if !isEdit{
            dict["email"] = objModel.arrEditProfileData[1].value
        }
        dict["name"] = objModel.arrEditProfileData[0].value
        dict["gender"] = objModel.arrEditProfileData[2].value
        //dict["van_number"] = objModel.arrEditProfileData[3].value
        return dict
    }
    
    func registerDriver(){
        showHud()
        KPWebCall.call.addProfile(image: profileImage, param: paramDict()) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? NSDictionary{
                weakSelf.showSuccMsg(dict: dict)
                let token = result.getStringValue(key: "token")
                _appDelegator.storeAuthorizationToken(strToken: token)
                _user = Driver.addUpdateEntity(key: "id", value: result.getStringValue(key: "id"))
                _user.initWith(dict: result)
                _appDelegator.saveContext()
                _appDelegator.navigateUserToHome()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Edit Profile WebCall Methods
extension EditProfileVC{
    func editProfile(){
        showHud()
        KPWebCall.call.editProfile(image: profileImage, param: paramDict()) {[weak self] (json, statusCode) in
            guard let weakSelf = self else{return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let res = dict["result"] as? NSDictionary{
                _user = Driver.addUpdateEntity(key: "id", value: res.getStringValue(key: "id"))
                _user.initWith(dict: res)
                _appDelegator.saveContext()
                weakSelf.showSuccMsg(dict: dict)
                weakSelf.navigationController?.popViewController(animated: true)
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
