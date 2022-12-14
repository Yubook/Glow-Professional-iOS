//
//  PrivacyPolicyVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/30/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: ParentViewController {
    @IBOutlet weak var webView : WKWebView!
    
    var arrData : [TermsPolicy] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getPrivacyPolicy()
        // Do any additional setup after loading the view.
    }
    
    func loadWebView(){
        for data in arrData{
            if data.selection == "Privacy"{
                webView.loadHTMLString(data.description, baseURL: nil)
            }
        }
    }

}

//MARK:-  Privacy WebCall Method
extension PrivacyPolicyVC {
    func getPrivacyPolicy(){
        showHud()
        KPWebCall.call .getTermsPolicy(param: ["for" : "2"]) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary{
                if let dictResult = dict["result"] as? [NSDictionary]{
                    for dictData in dictResult{
                        let terms = TermsPolicy(dict: dictData)
                        weakSelf.arrData.append(terms)
                    }
                    weakSelf.loadWebView()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
