//
//  HomeVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class HomeVC: ParentViewController {
    
    var arrHomeData : [EnumHome] = [.revenueCell,.bookingStateCell,.reviewsCell,.inProgessCell,.gallaryCell]
    @IBOutlet weak var demoView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

//MARK:- Others Methods
extension HomeVC{
    func prepareUI(){
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: _tabBarHeight + 10, right: 0)
    }
}

//MARK:- TableView Delegate & DataSource Methods
extension HomeVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrHomeData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : HomeTblCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: arrHomeData[indexPath.section].cellId, for: indexPath) as! HomeTblCell
        cell.prepareCell(data: arrHomeData[indexPath.section])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! HomeTblCell
        
        headerView.lblSectionTitle.text = arrHomeData[section].sectionTitle
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.widthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrHomeData[indexPath.section].cellHeight
    }
}
