//
//  AddPortfolioVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 01/12/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class AddPortfolioCollCell : UICollectionViewCell{
    @IBOutlet weak var imgSelected : UIImageView!
    @IBOutlet weak var btnSelected : UIButton!
    @IBOutlet weak var btnDelete : UIButton!
    
    
    func prepareCell(data: UIImage){
        imgSelected.image = data
    }
}

class AddPortfolioVC: ParentViewController {
    var arrSelectedImgs : [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

//MARK:- Others Methods
extension AddPortfolioVC{
    func prepareUI(){
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15)
    }
    
    @IBAction func btnSaveTapped(_ sender: UIButton){
        if !arrSelectedImgs.isEmpty{
            self.addPhotos()
        }else{
            self.showAlert(title: "Alert!", msg: "Please Added some Photos")
        }
    }
    
    @IBAction func btnAddImageTapped(_ sender: UIButton){
        if arrSelectedImgs.count >= 5{
            self.showAlert(title: "Warning!", msg: "Maximum Photos limit exceed!")
        }else{
            let pic = UIImagePickerController()
            self.prepareImagePicker(pictureController: pic)
            pic.delegate = self
        }
    }
    
    @IBAction func btnDeleteTapped(_ sender: UIButton){
        self.showAlertWithAction(title: "Alert!", msg: "Are you sure want Delete Photo?") { (_) in
            self.arrSelectedImgs.remove(at: sender.tag - 1)
            self.collectionView.reloadData()
        }
    }
}

//MARK:- CollectionView Delegate & DataSource Methods
extension AddPortfolioVC : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSelectedImgs.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : AddPortfolioCollCell
        
        if  indexPath.row == 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as! AddPortfolioCollCell
            cell.btnSelected.tag = indexPath.row
            return cell
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgs", for: indexPath) as! AddPortfolioCollCell
            cell.btnDelete.tag = indexPath.row
            cell.prepareCell(data: arrSelectedImgs[indexPath.row - 1])
            return cell
        }
    }
}

//MARK:- CollectionView Delegate FlowLayout Methods
extension AddPortfolioVC : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collHeight = 120.widthRatio
        let width = (collectionView.frame.size.width / 2) - 25
        return CGSize(width: width, height: collHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
}

//MARK:- Add Portfolio Methods
extension AddPortfolioVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func prepareImagePicker(pictureController : UIImagePickerController){
        let actionSheet = UIAlertController(title: "SelectType", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            pictureController.sourceType = .camera
            pictureController.cameraCaptureMode = .photo
            pictureController.allowsEditing = false
            self.present(pictureController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            pictureController.sourceType = .photoLibrary
            pictureController.allowsEditing = true
            self.present(pictureController, animated: true, completion:  nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker.sourceType == .camera{
            if let image = info[.originalImage] as? UIImage{
                self.arrSelectedImgs.append(image)
            }
        }else if picker.sourceType == .photoLibrary{
            if let image = info[.editedImage] as? UIImage{
                print(image)
                self.arrSelectedImgs.append(image)
            }
        }
        self.collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Alert Message Methods
extension AddPortfolioVC{
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithAction(title: String, msg: String, action: ((UIAlertAction) -> Void)? ){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: action))
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


//MARK:- Add Photos Web Call Methods
extension AddPortfolioVC{
    func addPhotos(){
        showHud()
        KPWebCall.call.addPortfolio(param: [:], imgs: arrSelectedImgs) {[weak self] (json, statusCode) in
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
