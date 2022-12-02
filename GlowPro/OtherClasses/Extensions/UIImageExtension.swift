//  Created by Tom Swindell on 10/12/2015.
//  Copyright © 2015 The App Developers. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import ImageIO

public extension UIImage {
    
    func mask(maskImage: UIImage) -> UIImage? {
        var maskedImage: UIImage? = nil
        
        let maskRef = maskImage.cgImage as CGImage?
        
        let mask = CGImage(maskWidth: maskRef!.width,
                           height: maskRef!.height,
                           bitsPerComponent: maskRef!.bitsPerComponent,
                           bitsPerPixel: maskRef!.bitsPerPixel,
                           bytesPerRow: maskRef!.bytesPerRow,
                           provider: maskRef!.dataProvider!, decode: nil, shouldInterpolate: false) as CGImage?
        
        let maskedImageRef = self.cgImage!.masking(mask!)
        
        maskedImage = UIImage(cgImage: maskedImageRef!)
        
        return maskedImage
    }
    
    class func createImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)//CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(size:CGSize)-> UIImage {
        
        let scale  = UIScreen.main.scale
        let newSize = CGSize(width: size.width  , height: size.height  )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        context!.interpolationQuality = CGInterpolationQuality.high
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIImageView{
    func rotateImageHalf(duration: Double, isForward: Bool){
        let rotation : CABasicAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotation.duration = duration
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = 1
        rotation.fillMode = CAMediaTimingFillMode.forwards
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: (isForward == true ? 3.14 : -3.14))
        self.layer.add(rotation, forKey: "rotate")
    }
}
extension UIImageView {
    func setupHexagonMask(lineWidth: CGFloat, color: UIColor, cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedPolygonPathInRect: bounds, lineWidth: lineWidth, sides: 6, cornerRadius: cornerRadius, rotationOffset: CGFloat.pi / 2.0).cgPath

        let mask = CAShapeLayer()
        mask.path = path
        mask.lineWidth = lineWidth
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        layer.mask = mask

        let border = CAShapeLayer()
        border.path = path
        border.lineWidth = lineWidth
        border.strokeColor = color.cgColor
        border.fillColor = UIColor.clear.cgColor
        layer.addSublayer(border)
    }
    
    
}
extension UIImage {
    var isPortrait:  Bool    { size.height > size.width }
    var isLandscape: Bool    { size.width > size.height }
    var breadth:     CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize  { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect  { .init(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        guard let cgImage = cgImage?
            .cropping(to: .init(origin: .init(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                              y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = false
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: format.scale, orientation: imageOrientation)
            .draw(in: .init(origin: .zero, size: breadthSize))
        }
    }
    
    func roundedImage() -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = imageView.frame.width / 2
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
}

//MARK:- For Map Pin
extension UIImage {
    

   
    
    static func imageByMergingImages(topImage: UIImage, bottomImage: UIImage, scaleForTop: CGFloat = 1.0) -> UIImage {
        let width = CGFloat(65.0)
        let height = CGFloat(65.0)
            let container = CGRect(x: 0, y: 0, width: width, height: height)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2.0)
            UIGraphicsGetCurrentContext()!.interpolationQuality = .high
            bottomImage.draw(in: container)

            let topWidth = width / scaleForTop
            let topHeight = height / scaleForTop
            let topX = (width / 2.0) - (topWidth / 2.0)
            let topY = (height / 2.0) - (topHeight / 2.0)

            topImage.draw(in: CGRect(x: topX, y: topY, width: topWidth, height: topHeight), blendMode: .normal, alpha: 1.0)
            let img = UIGraphicsGetImageFromCurrentImageContext()!
            return img
        }
}
