//
//  ReasonView.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ReasonView: UIViewController {
    @IBOutlet weak var lblReason : UILabel!
    @IBOutlet weak var btnReason : UILabel!
    
    @IBOutlet weak var txtView : UITextView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    
    enum Tapped{
        case cancel,done
    }
    var actionBlock : ((_ tapped : Tapped) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextView()
    }
    
    func handleTappedAction(block: @escaping (Tapped) -> ()){
        actionBlock = block
    }
    
    func prepareTextView(){
        txtView.layer.cornerRadius = 30
    }
}

//MARK:- TextView Delegate Methods
extension ReasonView : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if let str = textView.text{
            if str.count > 0{
                lblPlaceholder.isHidden = true
            }else{
                lblPlaceholder.isHidden = false
            }
        }
    }
}


//MARK:- Others Methods
extension ReasonView{
    @IBAction func btnRadioTapped(_ sender: UIButton){
        sender.isSelected.toggle()
    }
    
    @IBAction func btnSubmitTapped(_ sender: UIButton){
        actionBlock?(.done)
    }
}


