//
//  ReviewListTblCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/17/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import Cosmos

class ReviewListCollCell : UICollectionViewCell{
    @IBOutlet weak var imgs : UIImageView!
    @IBOutlet weak var btnZoom : UIButton!
    
    func prepareCell(data : ImageList){
        imgs.kf.setImage(with: data.imgUrl)
    }
}

class ReviewListTblCell: UITableViewCell {
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var ratingView : CosmosView!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var imgCollView : UICollectionView!
    @IBOutlet weak var lblTotalReview : UILabel!
    var arrImages : [ImageList] = []
    
    weak var parent : ReviewListVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareCell(data : Reviews){
        ratingView.rating = Double(data.rating) ?? 0.0
        ratingView.text = "\(data.rating) Star"
        lblMessage.text = data.message
        arrImages = data.arrimgList
        if let users = data.users{
            imgUser.kf.setImage(with: users.profileUrl)
            lblName.text = users.name
        }
    }
    
    @IBAction func btnImageTapped(_ sender: UIButton){
        let imgUrls = arrImages[sender.tag].imgUrl
        parent.performSegue(withIdentifier: "zoom", sender: imgUrls)
    }

}
//MARK:- CollectionView Delegate & DataSource Methods
extension ReviewListTblCell : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ReviewListCollCell
        
        cell = imgCollView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReviewListCollCell
        let objData = arrImages[indexPath.row]
        
        cell.btnZoom.tag = indexPath.row
        cell.prepareCell(data: objData)
        
        return cell
    }
}

//MARK:- CollectionView Delegate FlowLayout Methods
extension ReviewListTblCell : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collHeight = 100.widthRatio
        let collWidth = collHeight * 1.0
        
        return CGSize(width: collHeight, height: collWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
    }
}
