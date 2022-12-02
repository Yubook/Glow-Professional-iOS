//
//  CountryListCell.swift
//  GlowPro
//
//  Created by MutipzTechnology on 16/10/22.
//  Copyright © 2022 Devang Lakhani. All rights reserved.
//

import UIKit

class CountryTableCell: UITableViewCell {
    @IBOutlet weak var lblCountryFlag : UILabel!
    @IBOutlet weak var lblCountryName : UILabel!
    @IBOutlet weak var lblCountryPhoneCode : UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func prepareCell(countryObJ: CountryList, index: Int){
        lblCountryName.text = countryObJ.countryName
        lblCountryPhoneCode.text = "+\(countryObJ.countryPhoneCode)"
        lblCountryFlag.text = countryObJ.countryFlag
    }

}
