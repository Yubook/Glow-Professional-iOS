//
//  ZoomImageCollCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ZoomImageCollCell: UICollectionViewCell {
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var imgView : UIImageView!
    
    func prepareZoom() {
        let dblTapGesture = UITapGestureRecognizer(target: self, action: #selector(userDoubleTappedScrollview(recognizer:)))
        dblTapGesture.numberOfTapsRequired = 2
        imgView.addGestureRecognizer(dblTapGesture)
    }
    
    @objc func userDoubleTappedScrollview(recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else {
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale / 2.0, center: recognizer.location(in: recognizer.view))
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        if let imageV = self.imgView {
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = imageV.convert(center, from: scrollView)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect;
    }
    
}
