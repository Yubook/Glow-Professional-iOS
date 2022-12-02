//
//  NearByVC.swift
//  Fade
//
//  Created by Devang Lakhani  on 4/8/21.
//  Copyright © 2021 Devang Lakhani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import NotificationCenter
import MapKitGoogleStyler


class NearByVC: ParentViewController {
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var lblDriverLocation : UILabel!
    @IBOutlet weak var notiView : UIView!
    @IBOutlet weak var btnLocation : UIButton!
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation!
    var objUserLocation : DriverLocation!
    var orderId : String = ""
    var destiTitle : String = ""
    var destinationLocationObject : PreviousBooking!
    var isFirstCall : Bool = false
    var destiAdd: String = ""
    var lat : Double!
    var long : Double!
    var selectedAddress: SearchAddress!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KPWebCall.call.addInterNetListner()
        prepareUI()
        configureOverlayOnMap()
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
    override func viewWillAppear(_ animated: Bool) {
        _defaultCenter.addObserver(self, selector: #selector(willEnterForeGround), name: UIApplication.willEnterForegroundNotification, object: nil)
        addDeviceToken()
        setupLocationManager()
        if isFirstCall{
            orderId = ""
            destinationLocationObject = nil
        }
        if orderId != ""{
            getUserLocation()
        }
    }
}

//MARK:- Others Methods
extension NearByVC{
    func prepareUI(){
        setupLocationManager()
        
    }
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        checkStatus()
        addCustomPin()
    }
    
    @IBAction func btnNotificationTapped(_ sender: UIButton){
        navToNotification()
    }
    
    func navToNotification() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "NotificationVC") as! NotificationVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func btnLocationTapped(_ sender: UIButton){
        getUserCurrLocation()
        self.getAddressLocation()
    }
}

//MARK:- Open Map for Change Address
extension NearByVC{
    func getUserCurrLocation() {
        weak var controller: UIViewController! = self
        guard let lati = Double(_user.latitude) else {return}
        guard let long = Double(_user.longitude) else {return}        
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
            if let _ = location {
                self.currentLocation = CLLocation(latitude: lati, longitude: long)
                if let location = self.currentLocation {
                    self.getAddressFromLocation(location: location)
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getAddressFromLocation(location: CLLocation) {
        KPAPICalls.shared.addressFromlocation(location: location) { (address) in
            if let address = address{
                print(address)
            }
        }
    }
    
    func getAddressLocation() {
        self.view.endEditing(true)
        let mapVC = UIStoryboard(name: "KPLocation", bundle: nil).instantiateViewController(withIdentifier: "KPMapVC") as! KPMapVC
        mapVC.callBackBlock = {[weak self] address in
            guard let weakSelf = self else {return}
            weakSelf.currentLocation = address.location
            weakSelf.lat = address.lat
            weakSelf.long = address.long
            if address.name != nil{
                weakSelf.lblDriverLocation.text = address.name + ", " + address.city
            }else{
                weakSelf.lblDriverLocation.text = address.formatedAddress + "," + address.city + "," + address.state + "," + address.country
            }
            weakSelf.selectedAddress = address
            
        }
        
        self.present(mapVC, animated: true, completion: nil)
    }
}

//MARK:- Get Current Location
extension NearByVC{
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
}
//MARK:- AddPin Annotation
extension NearByVC{
    func addCustomPin(){
        guard let lati = Double(_user.latitude) else {return}
        guard let long = Double(_user.longitude) else {return}
        lblDriverLocation.text = _user.address
        
        let location = CLLocationCoordinate2D(latitude: lati, longitude: long)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setRegion(region, animated: true)
        //Pin
        let pin = CustomPin(pinTitle: _user.name, pinSubtitle: _user.address, location: location)
        mapView.addAnnotation(pin)
    }
}

//MARK:- MKMapView Delegate Methods
extension NearByVC : MKMapViewDelegate, CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let id = MKMapViewDefaultAnnotationViewReuseIdentifier
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView {
            if annotation.title == destiTitle {
                view.titleVisibility = .visible
                view.subtitleVisibility = .visible
                view.markerTintColor = .black
                view.glyphImage = UIImage(systemName: "ic_destination")
                view.glyphTintColor = .white
                return view
            }else{
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotation")
                getData { (img) in
                    guard let userImg = img else {return}
                    annotationView.image = self.drawImageWithProfilePic(pp: userImg, image: UIImage(named: "ic_black_pin")!)
                }
                annotationView.canShowCallout = true
                return annotationView
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->
    MKOverlayRenderer {
        // This is the final step. This code can be copied and pasted into your project
        // without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
        // for displaying the tile overlay.
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
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
}

//MARK:- Check Permissions
extension NearByVC{
    func checkStatus(){
        let status = CLLocationManager.authorizationStatus()
        switch status{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .denied,.restricted:
            self.prepareEnableLocation()
        case .authorizedWhenInUse,.authorizedAlways :
            self.dismiss(animated: true, completion: nil)
        default: break
        }
    }
    
    @objc func willEnterForeGround(){
        self.checkStatus()
    }
}


//MARK:- Location Popup
extension NearByVC{
    func prepareEnableLocation(){
        let location = EnableLocation(nibName: "EnableLocation", bundle: nil)
        location.modalPresentationStyle = .overFullScreen
        self.present(location, animated: false, completion: nil)
        location.handleTappedAction { tapped in
            if tapped == .done{
                self.dismiss(animated: true, completion: nil)
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
        }
    }
}

//MARK:- Get User Location WebCall Methods
extension NearByVC{
    func paramDriverDict() -> [String : Any]{
        var dict : [String : Any] = [:]
        dict["driver_id"] = _user.id
        dict["order_id"] = orderId
        return dict
    }
    func getUserLocation(){
        showHud()
        KPWebCall.call.getDirectionLocation(param: paramDriverDict()) {[weak self] (json, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideHud()
            if statusCode == 200, let dict = json as? NSDictionary, let result = dict["result"] as? NSDictionary{
                weakSelf.isFirstCall = true
                //weakSelf.showSuccMsg(dict: dict)
                let locDict = DriverLocation(dict: result)
                weakSelf.objUserLocation = locDict
                weakSelf.getDirectionAndDrawRoute()
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
}

//MARK:- Draw Route
extension NearByVC{
    func getDirectionAndDrawRoute(){
        guard let driverLat = Double(_user.latitude) else {return}
        guard let driverLong = Double(_user.longitude) else {return}
        
        let sourceLocation = CLLocationCoordinate2D(latitude: driverLat , longitude: driverLong)
        guard let orderLat = Double(destinationLocationObject.lat), let orderLong = Double(destinationLocationObject.long) else {return}
        let destinationLocation = CLLocationCoordinate2D(latitude: orderLat, longitude: orderLong)
        
        let sourcePlaceMarks = MKPlacemark(coordinate: sourceLocation,addressDictionary: nil)
        
        let destinationPlaceMarks = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMarks)
        let destiItem = MKMapItem(placemark: destinationPlaceMarks)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = _user.address
        
        if let location = sourcePlaceMarks.location{
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destiAnnotation = MKPointAnnotation()
        //get Address
        destiTitle = destinationLocationObject.users!.name
        destiAnnotation.title = destinationLocationObject.users?.name
        destiAnnotation.subtitle = destiAdd
        
        if let location = destinationPlaceMarks.location{
            destiAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.addAnnotations([sourceAnnotation,destiAnnotation])
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = sourceItem
        directionRequest.destination = destiItem
        directionRequest.transportType = .automobile
        
        //Calculate Direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let err = error{
                    print(err.localizedDescription)
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}


//MARK:- AddDevice ID And PushToken WebCall Methods
extension NearByVC{
    func paramDeviceIdTokenDict() -> [String : Any]{
        var dict : [String : Any] = [:]
        dict["device_id"] = _deviceId
        dict["push_token"] = _appDelegator.getFCMToken()
        dict["type"] = "1"
        dict["latest_latitude"] = "\(getCurrentLocation().lat)"
        dict["latest_longitude"] = "\(getCurrentLocation().long)"
        return dict
    }
    
    func addDeviceToken(){
        showHud()
        KPWebCall.call.addDeviceToken(param: paramDeviceIdTokenDict()) {[weak self] (json, statusCode) in
            guard let weakSelf = self, let dict = json as? NSDictionary else {return}
            weakSelf.hideHud()
            if statusCode == 200, let res = dict["result"] as? NSDictionary{
                if let isAvailble = res["availability"] as? Int{
                    if isAvailble == 0{
                        weakSelf.goToSlotData()
                    }
                    _userDefault.set(isAvailble, forKey: "availablity")
                }
                if let isRead = res["is_read"] as? Int{
                    weakSelf.notiView.isHidden = isRead == 0 ? true : false
                    _userDefault.set(isRead, forKey: "isNotificationRead")
                }
                let adminId = res.getIntValue(key: "customer_support_chat_id")
                _userDefault.set(adminId, forKey: "adminChatId")
            }else{
                weakSelf.showError(data: json, view: weakSelf.view)
            }
        }
    }
    
    func goToSlotData(){
        let vc = UIStoryboard(name: "Entry", bundle: nil).instantiateViewController(identifier: "SlotBookingVC") as! SlotBookingVC
        vc.isFromHome = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func drawImageWithProfilePic(pp: UIImage, image: UIImage) -> UIImage {
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
        let newImage = imageWithView(view: imgView)
        return newImage
    }
    
    
    func imageWithView(view: UIView) -> UIImage {
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
