//
//  CustomerDetailsCell.swift
//  GlowPro
//
//  Created by Devang Lakhani  on 4/19/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import Cosmos
import MapKit

class CustomerDetailsCell: UITableViewCell {
    @IBOutlet weak var collView : UICollectionView!
    @IBOutlet weak var lblBookedService : UILabel!
    @IBOutlet weak var lblTotalPay : UILabel!
    @IBOutlet weak var lblDateTime : UILabel!
    @IBOutlet weak var lblAddress : UILabel!
    @IBOutlet weak var imgMap : UIImageView!
    @IBOutlet weak var ratingView : CosmosView!
    @IBOutlet weak var lblReviewName : UILabel!
    @IBOutlet weak var roundView : UIView!
    @IBOutlet weak var btnDirection : UIButton!
    @IBOutlet weak var galleryView : UIView!
    
    weak var parentVc : CustomerBookingDetailsVC!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func prepareCell(data : CustomerDetailsModel,idx: Int){
        switch data.cellType {
        case .serviceCell:
            var serviceList : String{
                let strService = parentVc.objCustomerData.arrServices.map{$0.name}.filter{!$0.isEmpty}.joined(separator: ",")
                return strService
            }
            lblBookedService.text = serviceList
            lblTotalPay.text = "£\(parentVc.objCustomerData.totalPay)"
            if parentVc.objCustomerData.arrServices.first != nil{
                let firstService = parentVc.objCustomerData.arrServices.first!
                lblDateTime.text = firstService.strDate + convertFormat(time: firstService.slotTime)
            }
        case .addressCell:
            self.getAddressFromLatLong(pdblLatitude: parentVc.objCustomerData.lat, withLongitude: parentVc.objCustomerData.long)
            lblAddress.text = parentVc.objCustomerData.address
            self.parentVc.add = parentVc.objCustomerData.address
            let lat = Double(parentVc.objCustomerData.lat)!
            let long = Double(parentVc.objCustomerData.long)!
            let snapShotOption = self.getSnapShotOfMap(lat: lat, long: long)
            let snapShotter = MKMapSnapshotter(options: snapShotOption)
            snapShotter.start { (snapShot, error) in
                if error == nil{
                    let img = snapShot?.image
                    self.imgMap.image = img
                }else{
                    print(error!.localizedDescription)
                }
            }
        case .reviewCell:
            lblReviewName.text = data.reviewType
            ratingView.tag = idx
            ratingView.isUserInteractionEnabled = false
            if !parentVc.objCustomerData.arrUserReview.isEmpty{
                parentVc.tableView.isScrollEnabled = true
                self.prepareReviews(data: parentVc.objCustomerData)
            }else{
                self.roundView.isHidden = true
                parentVc.tableView.isScrollEnabled = false
            }
        case .galleryCell:
            collView.reloadData()
            collView.register(UINib(nibName: "EmptyCollCell", bundle: nil), forCellWithReuseIdentifier: "noDataCell")
        }
    }
}

//MARK:- Get Map SnapShot Methods
extension CustomerDetailsCell{
    func getSnapShotOfMap(lat : Double, long: Double) -> MKMapSnapshotter.Options{
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        let location = CLLocationCoordinate2DMake(lat, long)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapSnapshotOptions.region = region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = CGSize(width: 170.widthRatio, height: 124.widthRatio)
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        return mapSnapshotOptions
    }
}

//MARK:- CollectionView Delegate & DataSource Methods
extension CustomerDetailsCell : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if parentVc.objCustomerData.arrUserReview.isEmpty{
            return 1
        }else{
            return parentVc.objCustomerData.arrUserReview.first!.arrReviewImg.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if parentVc.objCustomerData.arrUserReview.isEmpty{
            let cell : EmptyCollCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noDataCell", for: indexPath) as! EmptyCollCell
            cell.setText(str: "No Images Availble")
            collView.isScrollEnabled = false
            collView.contentMode = .center
            return cell
        }
        let cell : CustomerBookingCollCell
        cell = collView.dequeueReusableCell(withReuseIdentifier: "gallaryCollCell", for: indexPath) as! CustomerBookingCollCell
        let obj = parentVc.objCustomerData.arrUserReview.first!.arrReviewImg[indexPath.row]
        cell.prepareCell(imgData: obj)
        return cell
    }
}

//MARK:- CollectionView DelegateFlow Layout Methods
extension CustomerDetailsCell : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if parentVc.objCustomerData.arrUserReview.isEmpty{
            let collHeight = collView.frame.size.height
            let collWidth = collView.frame.size.width
            return CGSize(width: collWidth, height: collHeight)
        }
        let collHeight = 90.widthRatio
        let collWidth = collHeight *  1.34
        return CGSize(width: collWidth, height: collHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }
}

extension CustomerDetailsCell{
    func convertFormat(time: String) -> String{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm"
        let showDate = inputFormatter.date(from: time)
        inputFormatter.dateFormat = "HH:mm a"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    func getAddressFromLatLong(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        var addressString : String = ""
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        let pm = placemarks! as [CLPlacemark]
                                        
                                        if pm.count > 0 {
                                            let pm = placemarks![0]
                                            
                                            if pm.subLocality != nil {
                                                addressString = addressString + pm.subLocality! + ", "
                                            }
                                            if pm.thoroughfare != nil {
                                                addressString = addressString + pm.thoroughfare! + ", "
                                            }
                                            if pm.locality != nil {
                                                addressString = addressString + pm.locality! + ", "
                                            }
                                            if pm.country != nil {
                                                addressString = addressString + pm.country! + ", "
                                                
                                            }
                                            if pm.postalCode != nil {
                                                addressString = addressString + pm.postalCode! + " "
                                            }
                                        }
                                        // self.parentVc.add = addressString
                                        // self.lblAddress.text = addressString
                                    })
    }
}


//MARK:- Review Manage
extension CustomerDetailsCell{
    func prepareReviews(data: PreviousBooking){
        var totalValueRating = 0.0
        var totalServiceRating = 0.0
        var totalHyginRating = 0.0
        var valueRate : Double!
        var serviceRate : Double!
        var hygineRate : Double!
        for (_,obj) in data.arrUserReview.enumerated(){
            totalValueRating += Double(obj.value)
            totalServiceRating += Double(obj.service)
            totalHyginRating += Double(obj.hygine)
        }
        valueRate = totalValueRating / Double(data.arrUserReview.count)
        serviceRate = totalServiceRating / Double(data.arrUserReview.count)
        hygineRate = totalHyginRating / Double(data.arrUserReview.count)
        if ratingView.tag == 3{
            self.ratingView.rating = serviceRate.isNaN ? 0.0 : serviceRate
        }else if ratingView.tag == 4{
            self.ratingView.rating = hygineRate.isNaN ? 0.0 : hygineRate
        }else{
            self.ratingView.rating = valueRate.isNaN ? 0.0 : valueRate
        }
    }
}
