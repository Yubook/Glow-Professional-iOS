//
//  CustomPin.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/21/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class CustomPin : NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title : String?
    var subtitle: String?
    var color : UIColor?
    
    init(pinTitle: String, pinSubtitle: String, location: CLLocationCoordinate2D){
        self.coordinate = location
        self.title = pinTitle
        self.subtitle = pinSubtitle
    }
    
    
}

class ImageAnnotationView: MKAnnotationView {
    private var imageView: UIImageView!

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.addSubview(self.imageView)

        self.imageView.layer.cornerRadius = 5.0
        self.imageView.layer.masksToBounds = true
    }

    override var image: UIImage? {
        get {
            return self.imageView.image
        }

        set {
            self.imageView.image = newValue
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
