//
//  PortfolioCollCell.swift
//  GlowPro
//
//  Created by Chirag Patel on 02/12/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class PortfolioCollCell: UICollectionViewCell {
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var imgPhotos : UIImageView!
    
    func prepareCell(data: Portfolio, index: Int){
        btnDelete.isHidden = false
        btnDelete.tag = index
        imgPhotos.kf.setImage(with: data.imgUrl)
    }
    
    func prepareUserCell(data: Portfolio){
        btnDelete.isHidden = true
        imgPhotos.kf.setImage(with: data.imgUrl)
    }
    
}
