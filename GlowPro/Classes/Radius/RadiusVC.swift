//
//  RadiusVC.swift
//  GlowPro
//
//  Created by Chirag Patel on 30/09/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import MapKit
import MapKitGoogleStyler

class RadiusVC: ParentViewController {
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var radiusSlider : UISlider!
    @IBOutlet weak var btnBack : UIButton!
    let locationManager = CLLocationManager()
    var regionRadius: CLLocationDistance = 700
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKAnnotationView!
    var mkcircle : MKCircle!
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMapUI()
    }
}

//MARK:- Others Methods
extension RadiusVC{
    func prepareMapUI(){
        if isEdit{
            radiusSlider.value = Float(_user.maxRadius)!
        }
        
        mapView.delegate = self
        //mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        btnBack.isHidden = isEdit ? false : true
        addCircle()
       // configureOverlayOnMap()
        addCustomPinData()
    }
    
    func configureOverlayOnMap() {
        guard let overlayFileURLString = Bundle.main.path(forResource: "google_maps_style", ofType: "json") else {
            return
        }
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
        
        // After that, you can create the tile overlay using MapKitGoogleStyler
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
            return
        }
        
        // And finally add it to your MKMapView
        mapView.addOverlay(tileOverlay)
    }
    
    func addCustomPinData(){
        guard let barberLatitude = Double(_user.latitude), let barberLongitude = Double(_user.longitude) else {return}
        let marker = CustomPointAnnotation(title: _user.name, subtitle: _user.address, coordinate: CLLocationCoordinate2D(latitude: barberLatitude, longitude: barberLongitude))
        
        self.centerMapOnLocation(location: CLLocation(latitude: Double(_user.latitude) ?? getCurrentLocation().lat, longitude:  Double(_user.longitude) ?? getCurrentLocation().long))
        self.mapView.addAnnotation(marker)
    }
    
    func addCircle(){
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: Double(_user.latitude) ?? getCurrentLocation().lat, longitude: Double(_user.longitude) ?? getCurrentLocation().long), radius: 100, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        mkcircle = MKCircle(center: CLLocationCoordinate2D(latitude: Double(_user.latitude) ?? getCurrentLocation().lat, longitude: Double(_user.longitude) ?? getCurrentLocation().long), radius: region.radius)
        mapView.addOverlay(mkcircle)
    }
    
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    @IBAction func btnContinueTapped(_ sender: UIButton){
        let minVal = Int(radiusSlider.minimumValue)
        let maxVal = Int(radiusSlider.value)
        self.updateRadius(param: ["min_radius" : minVal,"max_radius" :  maxVal])
    }
    
    @IBAction func radiusSliderChange(_ sender: UISlider){
        mapView.removeOverlay(mkcircle)
        let newRadius = radiusSlider.value * 100
        mkcircle = MKCircle (center: CLLocationCoordinate2D(latitude: Double(_user.latitude) ?? getCurrentLocation().lat, longitude: Double(_user.longitude) ?? getCurrentLocation().long), radius: CLLocationDistance(newRadius))
        mapView.addOverlay(mkcircle)
    }
}

//MARK:- MKMapView Delgate Methods
extension RadiusVC : MKMapViewDelegate,CLLocationManagerDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotations")
        getData { (img) in
            guard let userImg = img else {return}
            annotationView.image = self.drawImageWithProfilePicture(pp: userImg, image: UIImage(named: "ic_black_pin")!)
        }
        annotationView.canShowCallout = true
        return annotationView
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = .black
        circleRenderer.fillColor = .black
        circleRenderer.alpha = 0.2
        return circleRenderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
       // mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showError(msg: error.localizedDescription)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeOverlay(mkcircle)
        mkcircle = MKCircle(center : mapView.centerCoordinate, radius: CLLocationDistance(radiusSlider.value*100))
        mapView.addOverlay(mkcircle)
    }
}


//MARK:- Other Map Methods
extension RadiusVC{
    func getCurrentLocation() -> (lat : Double, long : Double){
        var getLatLong  = (lat : 0.0, long: 0.0)
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            if let currLocation = locationManager.location{
                getLatLong.lat = currLocation.coordinate.latitude
                getLatLong.long = currLocation.coordinate.longitude
            }
            
        }
        return getLatLong
    }
    
    func getData(completion: @escaping (UIImage?) -> ()) {
        guard let url = _user.profileUrl else {return}
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                let img = UIImage(data: data)
                completion(img)
            }
        }.resume()
    }
    
    func drawImageWithProfilePicture(pp: UIImage, image: UIImage) -> UIImage {
        let imgView = UIImageView(image: image)
        let picImgView = UIImageView(image: pp)
        picImgView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        imgView.addSubview(picImgView)
        picImgView.center.x = imgView.center.x - -3.5
        picImgView.center.y = imgView.center.y - 7
        picImgView.layer.cornerRadius = picImgView.frame.width/2
        picImgView.clipsToBounds = true
        imgView.setNeedsLayout()
        picImgView.setNeedsLayout()
        let newImage = imageWithsView(view: imgView)
        return newImage
    }
    
    
    func imageWithsView(view: UIView) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }

}

//MARK:- Update Radius WebCall Method
extension RadiusVC{
    func updateRadius(param:[String:Any]){
        showHud()
        KPWebCall.call.addRadius(param: param) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            if statusCode == 200{
                weakSelf.hideHud()
                weakSelf.showSuccMsg(dict: dict) {
                    _user.minRadius = "\(Int(weakSelf.radiusSlider.minimumValue))"
                    _user.maxRadius = "\(Int(weakSelf.radiusSlider.value))"
                    _appDelegator.saveContext()
                    _appDelegator.navigateUserToHome()
                }
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}
