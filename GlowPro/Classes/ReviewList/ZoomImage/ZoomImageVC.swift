//
//  ZoomImageVC.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 6/11/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit

class ZoomImageVC: ParentViewController {
    var arrUrls : [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK:- UICollectionView Delegate & DataSource Methods
extension ZoomImageVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ZoomImageCollCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ZoomImageCollCell
        cell.imgView.kf.setImage(with: arrUrls[indexPath.row], placeholder: _placeImage)
        cell.prepareZoom()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: _screenSize.width, height: _screenSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

