//
//  CustomPointAnnotation.swift
//  GlowPro
//
//  Created by Chirag Patel on 03/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import MapKit

class CustomPointAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var image: UIImage!
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
