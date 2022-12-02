//
//  AboutUsVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import WebKit

class AboutUsVC: ParentViewController {
    @IBOutlet weak var webView : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPage()
    }
}

//MARK:- Load Page
extension AboutUsVC{
    func loadPage(){
        let url = URL(string: "https://www.fadeapp.io/")
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = false
    }
}
