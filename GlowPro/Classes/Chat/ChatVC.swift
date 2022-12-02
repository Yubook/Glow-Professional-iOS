//
//  ChatVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/8/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ChatVC: ParentViewController {
    
    var arrSectionIndex : [(key : String, value: [UserChat])] = []
    
    var userObj : ChatList?
    var arrUsers : [UserChat] = []
    var arrAdmin : [UserChat]{
        return arrUsers.filter{$0.role == "admin"}
    }
    var arrOnlyUser : [UserChat]{
        return arrUsers.filter{$0.role == "user"}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        self.tableView.isHidden = true
        prepareConnectionObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SocketManager.shared.socket.status == .connected{
            SocketManager.shared.getInboxList()
        }
    }
    
}

//MARK:- Others Methods
extension ChatVC{
    func prepareUI(){
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: _tabBarHeight + 10, right: 0)
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresh)
        getNoDataCell()
    }
    @objc func refreshData() {
        SocketManager.shared.getInboxList()
    }
    
    func prepareConnectionObserver(){
        _defaultCenter.addObserver(self, selector: #selector(gotInboxList(noti:)), name: NSNotification.Name.init(_observerInboxListData), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageList"{
            let vc = segue.destination as! MessagesListVC
            if let objUser = sender as? UserChat{
                vc.objDataInbox = objUser
            }
        }
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension ChatVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrAdmin.count > 0  && arrOnlyUser.count > 0{
            return 2
        }
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0  ? arrAdmin.count : arrOnlyUser.isEmpty ? 1 : arrOnlyUser.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! ChatListTblCell
        if section == 0{
            sectionView.lblRoleName.text = "Admin"
        }else if arrOnlyUser.count > 0{
            sectionView.lblRoleName.text = "Users"
        }
        return sectionView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell : ChatListTblCell
            cell = tableView.dequeueReusableCell(withIdentifier: "msglistCell", for: indexPath) as! ChatListTblCell
            cell.prepareInboxUI(data: arrAdmin[indexPath.row])
            return cell
        }else{
            if arrUsers.isEmpty{
                let cell: NoDataTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath) as! NoDataTableCell
                cell.setText(str: "You have no Chat List")
                return cell
            }else if arrOnlyUser.count > 0 {
                let cell : ChatListTblCell
                cell = tableView.dequeueReusableCell(withIdentifier: "msglistCell", for: indexPath) as! ChatListTblCell
                if arrOnlyUser.count > 0 {
                    cell.prepareInboxUI(data: arrOnlyUser[indexPath.row])
                }
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 80.widthRatio : arrOnlyUser.isEmpty ? 100.widthRatio : 80.widthRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            guard !arrOnlyUser.isEmpty else {return}
            let objInbox = arrOnlyUser[indexPath.row]
            if objInbox.role == "user" &&  !objInbox.arrOrdersDetails.isEmpty{
                let data = objInbox.arrOrdersDetails.last!
                let service = data.arrServices.last!
                if data.isOrderCompleted == 0 && service.getTimeAndDate() > service.startChatTime && service.getTimeAndDate() < service.chatEndTime{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "messageList", sender: objInbox)
                    }
                }else{
                    self.showAlert(title: "", msg: "You can Chat with User Before 1 Hour of your Order Time")
                }
            }else{
                self.showAlert(title: "", msg: "You can Chat with User Order is Completed!!")
            }
        }else{
            let objAdmin = arrAdmin[indexPath.row]
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "messageList", sender: objAdmin)
            }
        }
    }
}


//MARK:- Get Inbox Data
extension ChatVC{
    func setListByDriver() {
        guard let obj = userObj else {return}
        let inboxDict =  Dictionary(grouping: obj.arrUsers, by: { $0.name })
        self.arrSectionIndex = Array(inboxDict)
        self.arrSectionIndex.sort { (obj, obj1) -> Bool in
            return obj1.key > obj.key
        }
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    @objc func gotInboxList(noti : NSNotification){
        if !refresh.isRefreshing {
            showHud()
        }
        if let jsonData = noti.userInfo?["inboxData"] as? NSDictionary {
            self.arrUsers = []
            if let driverChat = jsonData["users"] as? [NSDictionary]{
                for dictUser in driverChat{
                    let data = UserChat(dict: dictUser)
                    self.arrUsers.append(data)
                }
            }
            if let admin = jsonData["admin"] as? [NSDictionary]{
                for dictAdmin in admin{
                    let data = UserChat(dict: dictAdmin)
                    self.arrUsers.append(data)
                }
            }
            self.hideHud()
            self.refresh.endRefreshing()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        } else {
            self.showError(msg: kInternalError)
        }
    }
    
    func showAlert(title : String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
