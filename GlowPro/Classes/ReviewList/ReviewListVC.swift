//
//  ReviewListVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ReviewListVC: ParentViewController {
    
    var arrReviews : [Reviews] = []
    var loadMore = LoadMore()
    
    var arrFilterReview : [Reviews]{
        return arrReviews.filter{$0.toId == _user.id}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReviews()
        prepareUI()
        
    }
    
}
//MARK:- Others Methods
extension ReviewListVC{
    func prepareUI(){
        getNoDataCell()
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
    }
}


//MARK:- TableView Delegate & DataSource Methods
extension ReviewListVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrFilterReview.isEmpty {
            return 1
        }
        return section == 0 ? 1 : arrFilterReview.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ReviewListTblCell
        
        if indexPath.section == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "totalReviewCell", for: indexPath) as! ReviewListTblCell
            cell.lblTotalReview.text = "(\(arrFilterReview.count))"
            
            return cell
        }else{
            if arrFilterReview.isEmpty{
                let cell : NoDataTableCell
                cell = tableView.dequeueReusableCell(withIdentifier: "noDataCell") as! NoDataTableCell
                cell.setText(str: "No Reviews Available")
                return cell
            }
            cell = tableView.dequeueReusableCell(withIdentifier: "reviewListCell", for: indexPath) as! ReviewListTblCell
            cell.parent = self
            cell.prepareCell(data: arrFilterReview[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrFilterReview.isEmpty{
            return 50.widthRatio
        }else{
            return indexPath.section == 0 ? 45.widthRatio : 160.widthRatio
        }
    }
}

//MARK:- Reviews WebCall Methods
extension ReviewListVC{
    func getReviews(){
        if !refresh.isRefreshing && loadMore.index == 0 {
            showHud()
        }
        loadMore.isLoading = true
        KPWebCall.call.getReviews(param: ["limit" :loadMore.limit]) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            weakSelf.refresh.endRefreshing()
            weakSelf.loadMore.isLoading = false
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? [NSDictionary]{
                weakSelf.showSuccMsg(dict: dict)
                if weakSelf.loadMore.index == 0{
                    weakSelf.arrReviews = []
                }
                for data in result{
                    let objData = Reviews(dict: data)
                    weakSelf.arrReviews.append(objData)
                }
                if result.isEmpty{
                    weakSelf.loadMore.isAllLoaded = true
                }else{
                    weakSelf.loadMore.index += 1
                }
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- ZoomImage Methods
extension ReviewListVC{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zoom"{
            let vc = segue.destination as! ZoomImageVC
            if let url = sender as? URL{
                vc.arrUrls.append(url)
            }
        }
    }
}
