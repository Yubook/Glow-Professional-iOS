//
//  CustomerBookingDetailsVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class CustomerBookingDetailsVC: ParentViewController {
    
    @IBOutlet weak var hexaView : UIView!
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblCustomerName : UILabel!
    @IBOutlet weak var lblAddress : UILabel!
    @IBOutlet weak var btnChat : UIButton!
    
    var cellSelectedType : EnumBookingDetails!
    var arrCustomerData : [EnumCustomerDetails] = [.serviceCell,.addressCell,.galleryCell,.reviewCell]
    var objCustomerData :  PreviousBooking!
    var objReviewData : GetReview?
    var completion : ((GetReview?) -> ()) = {_ in}
    var add : String = ""
    var objData = CustomerDetailsData()
    var isChatOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getOrderReview()
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

//MARK:- Others Methods
extension CustomerBookingDetailsVC{
    func prepareUI(){
        prepareCustomerData()
        objData.prepareData()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
        
    }
    
    func prepareCustomerData(){
        btnChat.isHidden = objCustomerData.chat ? false : true
        if cellSelectedType == .some(.previousCell){
            btnChat.isEnabled = false
        }
        if cellSelectedType == .some(.currentCell) ||  cellSelectedType == .some(.featureCell) || cellSelectedType == .some(.previousCell){
            if let users = objCustomerData.users{
                imgProfile.contentMode = .scaleAspectFill
                imgProfile.kf.setImage(with: users.profileUrl)
                lblCustomerName.text = users.name
                lblAddress.text = users.address
            }
        }
    }
    
    @IBAction func btnGetDirectionTapped(_ sender: UIButton){
        if objCustomerData != nil{
            let orderId = objCustomerData.orderId
            self.performSegue(withIdentifier: "map", sender: (orderId,objCustomerData,add))
        }
    }
    
    @IBAction func btnChatTapped(_ sender: UIButton){
        let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(identifier: "MessagesListVC") as! MessagesListVC
        if objCustomerData != nil{
            chatVC.name = objCustomerData.users!.name
            chatVC.chatId = objCustomerData.chatId
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "map"{
            let vc = segue.destination  as! JTabBarController
            let map = vc.viewControllers?[0] as! NearByVC
            if let id = sender as? (String,PreviousBooking,String){
                map.orderId = id.0
                map.destinationLocationObject = id.1
                map.destiAdd = id.2
            }
        }
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension CustomerBookingDetailsVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return objData.arrData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomerDetailsCell
        cell = tableView.dequeueReusableCell(withIdentifier: objData.arrData[indexPath.section].cellType.cellId, for: indexPath) as! CustomerDetailsCell
        cell.parentVc = self
        let obj = objData.arrData[indexPath.section]
        cell.prepareCell(data: obj,idx: indexPath.section)
        if obj.cellType == .addressCell{
            cell.btnDirection.tag = indexPath.row
        }
        
        if cellSelectedType == .some(.currentCell) || cellSelectedType == .some(.featureCell){
            if obj.cellType == .galleryCell{
                cell.galleryView.isHidden = true
            }else if obj.cellType == .reviewCell{
                cell.roundView.isHidden = true
            }
        }else{
            if obj.cellType == .galleryCell{
                cell.galleryView.isHidden = false
            }else if obj.cellType == .reviewCell{
                cell.roundView.isHidden = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return objData.arrData[indexPath.section].cellType.cellHeight
    }
}


//MARK:- Get Order Review Web Call Methods
extension CustomerBookingDetailsVC{
    func paramDict() -> [String : Any]{
        var dict : [String : Any] = [:]
        var userId : String = ""
        if let users = objCustomerData.users, objCustomerData != nil{
            userId = users.id
        }
        if objCustomerData != nil{
            dict["order_id"] = objCustomerData.orderId
        }
        dict["from_id"] = userId
        dict["to_id"] = _user.id
        return dict
    }
}
