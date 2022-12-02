//
//  TimesCollCell.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class TimesCollCell: UICollectionViewCell {
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var selectedView : KPRoundView!
    
    func prepareCellData(data: AvailableSlots){
        selectedView.backgroundColor = data.isSelected ? #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        lblTime.textColor = data.isSelected ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        lblTime.text = data.time
    }
}
