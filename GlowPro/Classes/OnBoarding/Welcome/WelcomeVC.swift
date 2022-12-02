//
//  WelcomeVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/7/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class WelcomeVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

//MARK:- Others Methods
extension WelcomeVC{
    @IBAction func btnLoginTapped(_ sender: UIButton){
        self.performSegue(withIdentifier: "login", sender: nil)
    }
}
