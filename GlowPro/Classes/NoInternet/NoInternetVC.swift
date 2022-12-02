//
//  NoInternetVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 17/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import Reachability

enum EnumNoInternet{
    case isReachable
    case error
}

class NoInternetVC: ParentViewController {
    var internetStatus :  EnumNoInternet = .error
    let reachability = try?Reachability()

    //declare this inside of viewWillAppear

        
    

    override func viewDidLoad() {
        super.viewDidLoad()
        _defaultCenter.addObserver(self, selector: #selector(reachabilityChanged(note:)),name: .reachabilityChanged,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
        
        
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
      let reachability = note.object as! Reachability
        switch reachability.connection{
        case .unavailable:
            print("Network not reachable")
        case .cellular:
            print("Reachable via Cellular")
        case .wifi:
            print("Reachable via WiFi")
        case .none:
            print("Network not reachable")
        }
    }
}

//MARK:- Others Methods
extension NoInternetVC{
    @IBAction func btnTryAgainTapped(_ sender: UIButton){
        if internetStatus == .isReachable{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
