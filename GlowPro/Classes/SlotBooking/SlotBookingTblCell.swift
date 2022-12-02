//
//  SlotBookingTblCell.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class SlotBookingTblCell: UITableViewCell {
    @IBOutlet weak var timesCollView : UICollectionView!
    @IBOutlet weak var lblSection : UILabel!
    @IBOutlet weak var collHeight : NSLayoutConstraint!
    weak var parentVC : SlotBookingVC!
    var strDays = ""
}

//MARK:- CollectionView Delegate & DataSource Methods
extension SlotBookingTblCell : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if strDays == "Morning Availability"{
            return parentVC.arrSlots.filter{$0.section == "Morning Availability"}.count
        }else if strDays == "Night Availability"{
            return parentVC.arrSlots.filter{$0.section == "Night Availability"}.count
        }else if strDays == "Afternoon Availability"{
            return parentVC.arrSlots.filter{$0.section == "Afternoon Availability"}.count
        }else{
            return parentVC.arrSlots.filter{$0.section == "Evening Availability"}.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : TimesCollCell
        cell = timesCollView.dequeueReusableCell(withReuseIdentifier: "timingCell", for: indexPath) as! TimesCollCell
        if strDays == "Morning Availability"{
            cell.prepareCellData(data: parentVC.arrSlots.filter{$0.section == "Morning Availability"}[indexPath.row])
        }else if strDays == "Night Availability"{
            cell.prepareCellData(data: parentVC.arrSlots.filter{$0.section == "Night Availability"}[indexPath.row])
        }else if strDays == "Afternoon Availability"{
            cell.prepareCellData(data: parentVC.arrSlots.filter{$0.section == "Afternoon Availability"}[indexPath.row])
        }else{
            cell.prepareCellData(data: parentVC.arrSlots.filter{$0.section == "Evening Availability"}[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if strDays == "Morning Availability"{
            let objData = parentVC.arrSlots.filter{$0.section == "Morning Availability"}[indexPath.row]
            objData.isSelected.toggle()
           // self.timesCollView.reloadItems(at: [indexPath])
        }else if strDays == "Night Availability"{
            let objData = parentVC.arrSlots.filter{$0.section == "Night Availability"}[indexPath.row]
            objData.isSelected.toggle()
          //  self.timesCollView.reloadItems(at: [indexPath])
        }else if strDays == "Afternoon Availability"{
            let objData = parentVC.arrSlots.filter{$0.section == "Afternoon Availability"}[indexPath.row]
            objData.isSelected.toggle()
           // self.timesCollView.reloadItems(at: [indexPath])
        }else{
            let objData = parentVC.arrSlots.filter{$0.section == "Evening Availability"}[indexPath.row]
            objData.isSelected.toggle()
           // self.timesCollView.reloadItems(at: [indexPath])
        }
        self.timesCollView.reloadData()
    }
}

//MARK:- CollectionView Delegate Flow Layout Methods
extension SlotBookingTblCell : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = 33.widthRatio
        let cellWidth = (timesCollView.frame.size.width / 3.4) - 30
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
