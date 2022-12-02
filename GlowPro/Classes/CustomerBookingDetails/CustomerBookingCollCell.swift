//
//  CustomerBookingCollCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class CustomerBookingCollCell: UICollectionViewCell {
    @IBOutlet weak var imgPhotos : UIImageView!
    
    func prepareCell(imgData : NewReviewImages){
        imgPhotos.kf.setImage(with: imgData.imgUrl)
    }
}
