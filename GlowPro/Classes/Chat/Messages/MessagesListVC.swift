//
//  MessagesListVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/14/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import MessageInputBar
class MessagesListVC: ParentViewController {
    
    @IBOutlet weak var lblDriverName : UILabel!
    @IBOutlet var constBottomMsgBar: NSLayoutConstraint!
    
    
    private let messageInputBar = MessageInputBar()
    var objDataInbox : UserChat!
    
    var arrSectionMsg : [MessageSection]!
    var messages : String = ""
    var name = ""
    var chatId = ""
    //Messages
    var arrMessages : [Message] = []
    
    let textAttribute = [NSAttributedString.Key.font : UIFont.DUCEFontWith(.sfProDisplayRegular, size: 15.widthRatio)]
    let arrData : [EnumMessages] = [.timeCell,.senderCell,.receivedCell,.senderImage,.receivedImage]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        prepareUI()
        setKeyboard()
        prepareReceiverData()
        prepareConnectionObserver()
        setMessageBoxUI()
        if SocketManager.shared.socket.status == .connected {
            SocketManager.shared.getHistory(with: chatId == "" ? objDataInbox.groupId : chatId)
        }
    }
    override var inputAccessoryView: MessageInputBar {
        return messageInputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

//MARK:- Others Methods
extension MessagesListVC{
    func prepareUI(){
        //tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: messageInputBar.frame.height + 50, right: 0)
    }
    
    func prepareReceiverData(){
        lblDriverName.text = name == "" ? objDataInbox.name : name
    }
    
    func prepareConnectionObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.connectionStateChage), name: NSNotification.Name(rawValue: _observerConnectionStateChage), object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.getMessageHistory(noti:)), name: NSNotification.Name(rawValue: _observerGetMessageHistory), object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.getSentMsg(noti:)), name: NSNotification.Name(rawValue: _observerGetSentMessage), object: nil)
        //_defaultCenter.addObserver(self, selector: #selector(self.deletedMessage(noti:)), name: NSNotification.Name(_observerDeleteMessage), object: nil)
        connectionStateChage()
    }
    
    
    @objc func connectionStateChage() {
        switch SocketManager.shared.socket.status {
        case .connected:
            kprint(items: "Socket Connected")
            break
        case .connecting:
            kprint(items: "Socket Connecting")
            break
        case .disconnected:
            kprint(items: "Socket DisConnected")
            break
        case .notConnected:
            kprint(items: "Socket NotConnected")
            break
        }
    }
    
    func prepareSectionArray() {
        var dates: Set<String> = []
        arrSectionMsg = []
        for chatMsg in arrMessages {
            dates.insert(Date.localDateString(from: chatMsg.msgDate))
        }
        for dateStr in dates{
            var tempMsgs = arrMessages.filter({ (msg) -> Bool in
                let mDate = Date.localDateString(from: msg.msgDate)
                return mDate == dateStr
            })
            if !tempMsgs.isEmpty{
                tempMsgs = tempMsgs.sorted(by: { (msg1, msg2) -> Bool in
                    return msg1.msgDate! < msg2.msgDate!
                })
                
                let section = MessageSection(msg: tempMsgs)
                arrSectionMsg.append(section)
            }
        }
        arrSectionMsg = arrSectionMsg.sorted { (sec1, sec2) -> Bool in
            return sec1.date < sec2.date
        }
        tableView.reloadData()
    }
    
    func setKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            constBottomMsgBar.constant = kbSize.height
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            }) { (flag) in
                guard self.arrSectionMsg != nil else {return}
                if !self.arrSectionMsg.isEmpty {
                    self.scrollToIndexChat(section: self.arrSectionMsg.count - 1, index: self.arrSectionMsg[self.arrSectionMsg.count - 1].msgs.count - 1, animate: true)
                }
            }
        }
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            constBottomMsgBar.constant = _bottomAreaSpacing + 64
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setMessageBoxUI() {
        messageInputBar.backgroundView.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8745098039, blue: 0.8431372549, alpha: 1)
        messageInputBar.inputTextView.placeholder = "Type your message here"
        
        // messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
        messageInputBar.inputTextView.placeholderTextColor = .black
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 40)
        messageInputBar.inputTextView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        messageInputBar.inputTextView.layer.cornerRadius = 10
        
        let btnAttachment = InputBarButtonItem()
        btnAttachment.setImage(#imageLiteral(resourceName: "ic_cam"), for: .normal)
        btnAttachment.addTarget(self, action: #selector(btnOpenImagePicker(_:)), for: .touchUpInside)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 30, animated: false)
        messageInputBar.setStackViewItems([btnAttachment], forStack: .left, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton,InputBarButtonItem.fixedSpace(10)], forStack: .right, animated: false)
        messageInputBar.inputTextView.textColor = UIColor.black
        messageInputBar.inputTextView.font = UIFont.DUCEFontWith(.sfProDisplayRegular, size: 15.widthRatio)
        let sendButtonHeight: CGFloat = 40
        messageInputBar.setRightStackViewWidthConstant(to: sendButtonHeight + 10, animated: false)
        messageInputBar.sendButton.contentMode = .center
        messageInputBar.separatorLine.height = 0
        messageInputBar.sendButton.isEnabled = true
        messageInputBar.sendButton.setImage(UIImage(named: "ic_send"), for: .normal)
        messageInputBar.sendButton.setSize(CGSize(width: sendButtonHeight, height: sendButtonHeight), animated: false)
        messageInputBar.sendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        
        messageInputBar.sendButton.tintColor = #colorLiteral(red: 0.3921568627, green: 0.3882352941, blue: 0.4078431373, alpha: 1)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.textViewPadding.right = -40
        
        messageInputBar.delegate = self
        messageInputBar.inputTextView.delegate = self
        messageInputBar.maxTextViewHeight = 100
        messageInputBar.shouldAutoUpdateMaxTextViewHeight = false
        scrollToBottom(animate: true)
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton){
        if let idx = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView) {
            let objMsg = self.arrSectionMsg[idx.section].msgs[idx.row]
            if objMsg.isMediaMsg {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "zoom", sender: objMsg.mediaUrl)
                }
            }
        }
    }
    
    @IBAction func btnDeleteTapped(_ sender: UIButton){
        if let idx = IndexPath.indexPathForCellContainingView(view: sender, inTableView: tableView){
            let objMsg = self.arrSectionMsg[idx.section].msgs[idx.row]
            self.showAlertWithAction(title: "Alert!", msg: "Are you sure want to Delete this Message?") { (_) in
                self.deleteMessage(objMsg.id)
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zoom" {
            let destVC = segue.destination as! ZoomImageVC
            destVC.arrUrls = [sender as! URL]
        }
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension MessagesListVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSectionMsg == nil ? 0 : arrSectionMsg.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSectionMsg[section].msgs.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! MessagesTblCell
        headerView.lblDate.text = arrSectionMsg[section].date.getChatHeaderDate()
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MessagesTblCell
        
        let objMsg = self.arrSectionMsg[indexPath.section].msgs[indexPath.row]
        
        let mediaCellId = objMsg.isSenderMsg ? "senderImageCell" : "receivedImageCell"
        let msgCellId = objMsg.isSenderMsg ? "senderCell" : "receivedCell"
        
        let cellId = objMsg.isMediaMsg ? mediaCellId : msgCellId
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessagesTblCell
        cell.selectionStyle = .none
        
        if objMsg.isMediaMsg{
            cell.imgView.kf.indicatorType = .activity
            cell.imgView.kf.setImage(with: objMsg.mediaUrl)
            cell.btnZoom.tag = indexPath.section
        }else {
            cell.btnDelete.tag = indexPath.section
            cell.lblMessage.setAttributedText(texts: ["\(objMsg.message)"], attributes: [textAttribute])
        }
        cell.lblMsgTime.text = objMsg.strTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.widthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let objData = arrSectionMsg[indexPath.section].msgs[indexPath.row]
        return objData.type.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.messageInputBar.inputTextView.becomeFirstResponder(){
            self.messageInputBar.inputTextView.resignFirstResponder()
        }
        // let objData = arrSectionMsg[indexPath.section].msgs[indexPath.row]
        
    }
}

//MARK:- Send Messages
extension MessagesListVC{
    func sendImage(_ img: UIImage) {
        DispatchQueue.main.async {
            self.showHud()
        }
        if SocketManager.shared.socket.status == .connected {
            SocketManager.shared.sendMediaMsg(to: chatId == "" ? objDataInbox.groupId : chatId, media: img)
        } else {
            SocketManager.shared.connectSockect()
        }
    }
    func sendNewMsg(_ msg: String) {
        if SocketManager.shared.socket.status == .connected {
            SocketManager.shared.sendNewMessage(to: chatId == "" ? objDataInbox.groupId : chatId, textMsg: msg)
        } else {
            SocketManager.shared.connectSockect()
        }
    }
    
    func deleteMessage(_ id : String){
        DispatchQueue.main.async {
            // self.showHud()
        }
        if SocketManager.shared.socket.status == .connected{
            SocketManager.shared.deleteMessage(messageId: id)
        }else{
            SocketManager.shared.connectSockect()
        }
    }
}


//MARK:- Get And Sent Message History
extension MessagesListVC {
    
    @objc func getMessageHistory(noti: Notification) {
        hideHud()
        if let jsonData = noti.userInfo?["msgHistory"] as? NSDictionary {
            if let allMsgsDict = jsonData["messageData"] as? [NSDictionary] {
                self.hideHud()
                self.arrMessages = []
                allMsgsDict.forEach { (dictData) in
                    self.arrMessages.append(Message(dict: dictData))
                }
            }
            self.prepareSectionArray()
            if !arrMessages.isEmpty {
                self.scrollToIndexChat(section: self.arrSectionMsg.count - 1, index: self.arrSectionMsg[self.arrSectionMsg.count - 1].msgs.count - 1, animate: false)
            }
        } else {
            self.showError(msg: kInternalError)
        }
    }
    
    @objc func getSentMsg(noti: Notification) {
        hideHud()
        
        if let jsonData = noti.userInfo?["sentMsg"] as? NSDictionary {
            if let resultDict = jsonData["result"] as? NSDictionary {
                let objMsg = Message(dict: resultDict)
                let groupId = chatId == "" ? objDataInbox.groupId : chatId
                if objMsg.groupId == groupId || chatId == groupId{
                    self.arrMessages.append(objMsg)
                }
                self.prepareSectionArray()
                if !arrSectionMsg.isEmpty {
                    self.scrollToIndexChat(section: self.arrSectionMsg.count - 1, index: self.arrSectionMsg[self.arrSectionMsg.count - 1].msgs.count - 1, animate: true)
                }
            } else {
                self.showError(msg: kInternalError)
            }
        }
    }
}


//MARK:- Open Media Picker
extension MessagesListVC{
    
    @objc func btnOpenImagePicker(_ sender: UIButton) {
        let pic = UIImagePickerController()
        self.prepareImagePicker(pictureController: pic)
        pic.delegate = self
    }
}

//MARK:- MessageInputbarDelegate Methods
extension MessagesListVC : MessageInputBarDelegate,UITextViewDelegate{
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = text.trimmedString()
        if !message.isEmpty {
            sendNewMsg(message)
        }
        messageInputBar.inputTextView.text.removeAll()
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        inputBar.sendButton.isEnabled = true
        
        inputBar.sendButton.setImage(UIImage(named: "ic_send"), for: .normal)
        messageInputBar.reloadInputViews()
    }
}


//MARK:- Image Picker Methods
extension MessagesListVC{
    func prepareImagePicker(pictureController : UIImagePickerController){
        let actionSheet = UIAlertController(title: "SelectType", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            pictureController.sourceType = .camera
            pictureController.cameraCaptureMode = .photo
            pictureController.allowsEditing = false
            self.present(pictureController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "PhotoLibrery", style: .default, handler: { _ in
            pictureController.sourceType = .photoLibrary
            pictureController.allowsEditing = true
            self.present(pictureController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}

//MARK:- UIImagePickerDelegate Methods
extension MessagesListVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            self.sendImage(image)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlertWithAction(title: String, msg: String, action: ((UIAlertAction) -> Void)? ){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: action))
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK:- Chat Bubble View
class SenderBubble : UIView{
    @IBInspectable var radious: CGFloat = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.shadowRadius = radious
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
    }
    
    func updateShadow(){
        self.roundCorners(corners: [.topRight,.topLeft,.bottomLeft], radius: radious)
    }
}

class ReciverBubble : UIView{
    @IBInspectable var radious: CGFloat = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.shadowRadius = radious
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
    }
    
    func updateShadow(){
        self.roundCorners(corners: [.topRight,.topLeft,.bottomRight], radius: radious)
    }
}
