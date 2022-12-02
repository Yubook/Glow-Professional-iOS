//
//  PortfolioVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 02/12/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class PortfolioVC: ParentViewController {
    @IBOutlet weak var segmentChange : UISegmentedControl!
    @IBOutlet weak var btnAdd : UIButton!
    
    var typeChanged : EnumPortfolio = .barber
    var arrBarberPortfolio : [Portfolio] = []
    var arrUserPortfolio : [Portfolio] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSegment()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPortfolio()
    }
}

//MARK:- Others Methods
extension PortfolioVC{
    func prepareUI(){
        btnAdd.isHidden = typeChanged == .barber ? false : true
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 10, right: 15)
    }
    
    func prepareSegment() {
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)]
        segmentChange.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        segmentChange.setTitleTextAttributes(normalTextAttributes, for: .normal)
    }
    
    @IBAction func segmentTapped(_ sender: UISegmentedControl){
        self.typeChanged = EnumPortfolio(val: sender.selectedSegmentIndex)
        self.prepareSegment()
        btnAdd.isHidden = typeChanged == .barber ? false : true
        if typeChanged == .barber{
            if arrBarberPortfolio.isEmpty{
                collectionView.isHidden = true
            }else{
                collectionView.isHidden = false
                collectionView.reloadData()
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }else{
            if arrUserPortfolio.isEmpty{
                collectionView.isHidden = true
            }else{
                collectionView.isHidden = false
                collectionView.reloadData()
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    
    @IBAction func btnDeleteTapped(_ sender: UIButton){
        let objData = arrBarberPortfolio[sender.tag]
        self.showAlertWithAction(title: "Alert!", msg: "Are you Sure want delete Photo?") { (_) in
            self.removePhotos(id: objData.id)
        }
    }
    
    @IBAction func btnAddPortfolioTapped(_ sender: UIButton){
        self.performSegue(withIdentifier: "addPortfolio", sender: nil)
    }
}

//MARK:- CollectionView Delegate and DataSource Methods
extension PortfolioVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeChanged == .barber ? arrBarberPortfolio.count : arrUserPortfolio.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : PortfolioCollCell
        if typeChanged == .barber{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgs", for: indexPath) as! PortfolioCollCell
            cell.prepareCell(data: arrBarberPortfolio[indexPath.row], index: indexPath.row)
            return cell
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgs", for: indexPath) as! PortfolioCollCell
            cell.prepareUserCell(data: arrUserPortfolio[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "ZoomImageVC") as! ZoomImageVC
        if typeChanged == .barber{
            if !arrBarberPortfolio.isEmpty{
                let objbarber = arrBarberPortfolio[indexPath.row]
                vc.arrUrls.append(objbarber.imgUrl!)
            }
        }else{
            if !arrUserPortfolio.isEmpty{
                let objUser = arrUserPortfolio[indexPath.row]
                vc.arrUrls.append(objUser.imgUrl!)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK:- CollectionViewDelegate FlowLayout Methods
extension PortfolioVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = 120.widthRatio
        let cellWidth = (collectionView.frame.size.width / 2) - 25
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
}

//MARK:- Get Portfolio WebCall Methods
extension PortfolioVC{
    func getPortfolio(){
        showHud()
        KPWebCall.call.getPortfolio(param: [:]) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200, let dictResult = dict["result"] as? NSDictionary{
                weakSelf.hideHud()
                //weakSelf.showSuccMsg(dict: dict)
                if let barberPortfolio = dictResult["barberPortfolio"] as? NSDictionary{
                    weakSelf.arrBarberPortfolio = []
                    if let arrBarberPortfolio = barberPortfolio["data"] as? [NSDictionary]{
                        for dictBarber in arrBarberPortfolio{
                            let objData = Portfolio(dict: dictBarber)
                            weakSelf.arrBarberPortfolio.append(objData)
                        }
                    }
                    if let dictUser = dictResult["reviewPortfolio"] as? NSDictionary{
                        weakSelf.arrUserPortfolio = []
                        if let arrUserReview = dictUser["data"] as? [NSDictionary]{
                            for dictReview in arrUserReview{
                                let objData = Portfolio(dict: dictReview)
                                weakSelf.arrUserPortfolio.append(objData)
                            }
                        }
                    }
                    weakSelf.collectionView.isHidden = weakSelf.arrBarberPortfolio.isEmpty ? true : false
                    weakSelf.collectionView.reloadData()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Delete Portfolio WebCall Methods
extension PortfolioVC{
    func removePhotos(id: String){
        showHud()
        KPWebCall.call.deletePortfolio(param: ["portfolio_id" : id]) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                weakSelf.showSuccMsg(dict: dict) {
                    weakSelf.getPortfolio()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
//MARK:- Alert Message Methods
extension PortfolioVC{
    func showAlertWithAction(title: String, msg: String, action: ((UIAlertAction) -> Void)? ){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: action))
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
