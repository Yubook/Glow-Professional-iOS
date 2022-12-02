import Foundation
import Alamofire

// MARK: Web Operation
class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}


//let _baseUrl = " " // Live Url
let _baseUrl = "http://18.130.93.203/fade_barber_new_backend/public/api/mobile/" // Dev Url
let _storage = "http://18.130.93.203/fade_barber_new_backend/public"

let _socketUrl = "http://18.130.93.203:8081" //Dev

typealias WSBlock = (_ json: Any?, _ flag: Int) -> ()
typealias WSProgress = (Progress) -> ()?
typealias WSFileBlock = (_ path: String?, _ error: Error?) -> ()

class KPWebCall:NSObject{
    
    static var call: KPWebCall = KPWebCall()
    
    let manager: SessionManager
    var networkManager: NetworkReachabilityManager = NetworkReachabilityManager()!
    var headers: HTTPHeaders = [
        "Accept": "application/json",
        "device_type" : _deviceType,
        "device_token" : _appDelegator.getFCMToken()
    ]
    var toast: ValidationToast!
    var paramEncode: ParameterEncoding = URLEncoding.default
    let timeOutInteraval: TimeInterval = 60
    var successBlock: (String, HTTPURLResponse?, AnyObject?, WSBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, WSBlock) -> Void
    
    override init() {
        manager = Alamofire.SessionManager.default
        
        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res{
                kprint(items: "Response Code: \(response.statusCode)")
                kprint(items: "Response(\(relativePath)): \(String(describing: respObj))")
                
                if response.statusCode == 200 {
                    block(respObj, response.statusCode)
                } else {
                    if response.statusCode == 401{
                        block([_appName: kInternetDown] as AnyObject, response.statusCode)
                           SocketManager.shared.disConnect()
                        _appDelegator.removeUserInfoAndNavToLogin()
                    } else {
                           // SocketManager.shared.disConnect()
                        block(respObj, response.statusCode)
                    }
                }
            } else {
                 SocketManager.shared.disConnect()
                // There might me no case this can get execute
                block(nil, 404)
            }
        }
        
        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            if let response = res {
                kprint(items: "Response Code: \(response.statusCode)")
                kprint(items: "Error Code: \(error.code)")
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                    let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if errorDict != nil {
                        kprint(items: "Error(\(relativePath)): \(errorDict!)")
                        block(errorDict!, response.statusCode)
                    }  else if response.statusCode == 404 {
                        block([_appName: kTokenExpire] as AnyObject, response.statusCode)
                          SocketManager.shared.disConnect()
                        _appDelegator.removeUserInfoAndNavToLogin()
                    } else {
                        let code = response.statusCode
                        block(nil, code)
                    }
                } else if response.statusCode == 401{
                    block([_appName: kInternetDown] as AnyObject, response.statusCode)
                     SocketManager.shared.disConnect()
                    _appDelegator.removeUserInfoAndNavToLogin()
                }else {
                    block(nil, response.statusCode)
                }
                // If response not found rely on error code to find the issue
            } else if error.code == -1009  {
                 SocketManager.shared.disConnect()
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kInternetDown] as AnyObject, error.code)
                return
            }  else if error.code == 404 {
                SocketManager.shared.disConnect()
                block([_appName: kTokenExpire] as AnyObject, error.code)
                _appDelegator.removeUserInfoAndNavToLogin()
            } else if error.code == -1003  {
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kHostDown] as AnyObject, error.code)
                return
            } else if error.code == -1001  {
                kprint(items: "Error(\(relativePath)): \(error)")
                SocketManager.shared.disConnect()
                block([_appName: kTimeOut] as AnyObject, error.code)
                return
            } else if error.code == 1004  {
                SocketManager.shared.disConnect()
                kprint(items: "Error(\(relativePath)): \(error)")
                block([_appName: kInternetDown] as AnyObject, error.code)
                return
            } else {
                SocketManager.shared.disConnect()
                kprint(items: "Error(\(relativePath)): \(error)")
                block(nil, error.code)
            }
        }
        super.init()
        addInterNetListner()
    }
    
    deinit {
        networkManager.stopListening()
    }
}

// MARK: Other methods
extension KPWebCall{
    func getFullUrl(relPath : String) throws -> URL{
        do{
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www"){
                return try relPath.asURL()
            }else{
                return try (_baseUrl+relPath).asURL()
            }
        }catch let err{
            throw err
        }
    }
    
    func setAccesTokenToHeader(token:String){
        manager.adapter = AccessTokenAdapter(accessToken: token)
    }
    
    func removeAccessTokenFromHeader(){
        manager.adapter = nil
    }
}

// MARK: - Request, ImageUpload and Dowanload methods
extension KPWebCall{
    
    func getRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, timeout: TimeInterval? = nil, block: @escaping WSBlock)-> DataRequest? {
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            var req = try URLRequest(url: getFullUrl(relPath: relPath), method: HTTPMethod.get, headers: (headerParam ?? headers))
            req.timeoutInterval = timeout ?? timeOutInteraval
            let encodedURLRequest = try paramEncode.encode(req, with: param)
            return Alamofire.request(encodedURLRequest).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func postRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, timeout: TimeInterval? = nil, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            var req = try URLRequest(url: getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers))
            req.timeoutInterval = timeout ?? timeOutInteraval
            let encodedURLRequest = try paramEncode.encode(req, with: param)
            
            return Alamofire.request(encodedURLRequest).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func putRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            return manager.request(try getFullUrl(relPath: relPath), method: HTTPMethod.put, parameters: param, encoding: paramEncode, headers: (headerParam ?? headers)).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func deleteRequest(relPath: String, param: [String: Any]?, headerParam: HTTPHeaders?, block: @escaping WSBlock)-> DataRequest?{
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            return manager.request(try getFullUrl(relPath: relPath), method: HTTPMethod.delete, parameters: param, encoding: paramEncode, headers: (headerParam ?? headers)).responseJSON { (resObj) in
                switch resObj.result{
                case .success:
                    if let resData = resObj.data{
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse{
                            kprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        }catch let error{
            kprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    func uploadImage(relPath: String,img: UIImage?, param: [String: Any]?, withName : String = "profile" ,comress: CGFloat,headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            manager.upload(multipartFormData: { (formData) in
                if let image = img {
                    formData.append(image.jpegData(compressionQuality: comress)!, withName: withName, fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint( items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint( items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint( items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    
    func uploadVideo(relPath: String, vidFileUrl: URL, param: [String: Any]?, name : String ,headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            manager.upload(multipartFormData: { (formData) in
                formData.append(vidFileUrl, withName: name, fileName: "video.mp4", mimeType: "video/mp4")
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint( items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint( items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint( items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func uploadAudio(relPath: String, audioFileUrl: URL, param: [String: Any]?, name : String ,headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            kprint(items: "Url: \(try getFullUrl(relPath: relPath))")
            kprint(items: "Param: \(String(describing: param))")
            manager.upload(multipartFormData: { (formData) in
                formData.append(audioFileUrl, withName: name, fileName: "audio.m4a", mimeType: "audio/m4a")
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint( items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint( items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint( items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func uploadMultipleImages(relPath: String,imgs: [UIImage?],param: [String: Any]?, withName: String = "FileData", headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            manager.upload(multipartFormData: { (formData) in
                for (_,img) in imgs.enumerated(){
                    if let _ = img{
                        formData.append(img!.jpegData(compressionQuality: 0.6)!, withName: withName, fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                }
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint(items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint(items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func dowanloadFile(relPath : String, saveFileUrl: URL, progress: WSProgress?, block: @escaping WSFileBlock){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (saveFileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        do{
            manager.download(try getFullUrl(relPath: relPath), to: destination).downloadProgress { (prog) in
                progress?(prog)
            }.response { (responce) in
                if let path = responce.destinationURL?.path{
                    block(path, responce.error)
                }else{
                    block(nil, responce.error)
                }
            }.resume()
        }catch{
            block(nil, nil)
        }
    }
    
    func uploadMultipleImgNew(relPath: String,imgs: [UIImage?], headerParam: HTTPHeaders?, block: @escaping WSBlock, progress: WSProgress?){
        do{
            manager.upload(multipartFormData: { (formData) in
                for (i,_) in imgs.enumerated(){
                    formData.append(imgs[i]!.jpegData(compressionQuality: 0.6)!, withName: "images[\(i)]", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint(items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint(items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func uploadMultipleImgNewOne(relPath: String,param:[String:Any]?,imgs: [UIImage?], headerParam: HTTPHeaders?,keys: [String], block: @escaping WSBlock, progress: WSProgress?){
        do{
            manager.upload(multipartFormData: { (formData) in
                for (i,_) in imgs.enumerated(){
                    formData.append(imgs[i]!.jpegData(compressionQuality: 0.6)!, withName: "\(keys[i])", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                if let _ = param{
                    for (key, value) in param!{
                        formData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
                
            }, to: try getFullUrl(relPath: relPath), method: HTTPMethod.post, headers: (headerParam ?? headers), encodingCompletion: { encoding in
                switch encoding{
                case .success(let req, _, _):
                    req.uploadProgress(closure: { (prog) in
                        progress?(prog)
                    }).responseJSON { (resObj) in
                        switch resObj.result{
                        case .success:
                            if let resData = resObj.data{
                                do {
                                    let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                                    self.successBlock(relPath, resObj.response, res, block)
                                } catch let errParse{
                                    kprint(items: errParse)
                                    self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                                }
                            }
                            break
                        case .failure(let err):
                            kprint(items: err)
                            self.errorBlock(relPath, resObj.response, err as NSError, block)
                            break
                        }
                    }
                    break
                case .failure(let err):
                    kprint(items: err)
                    self.errorBlock(relPath, nil, err as NSError, block)
                    break
                }
            })
        }catch let err{
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
}


// MARK: - Internet Availability
extension KPWebCall{
    func addInterNetListner() {
        networkManager.startListening()
        networkManager.listener = { (status) -> Void in
            if status == NetworkReachabilityManager.NetworkReachabilityStatus.notReachable{
                print("No InterNet")
                if self.toast == nil{
                    self.toast = KPValidationToast.shared.showStatusMessageForInterNet(message: kInternetDown)
                }
            } else {
                print("Internet Avail")
                if self.toast != nil{
                    self.toast.animateOutInternetToast(duration: 0.2, delay: 0.2, completion: { () -> () in
                        self.toast.removeFromSuperview()
                        self.toast = nil
                    })
                }
            }
        }
    }
    
    func isInternetAvailable() -> Bool {
        if networkManager.isReachable{
            return true
        }else{
            return false
        }
    }
}

// MARK:- Entry WEB CALL
extension KPWebCall {
    func loginDriver(param : [String : Any], block : @escaping WSBlock){
        kprint(items: "----------- Login Driver --------")
        let relPath = "login"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addProfile(image : UIImage?,param: [String : Any], block : @escaping WSBlock){
        kprint(items: "----------- Save Profile Details-------")
        let relPath = "addProfile"
        uploadImage(relPath: relPath, img: image, param: param, comress: 0.25, headerParam: nil, block: block, progress: nil)
    }
    
    func editProfile(image: UIImage?, param: [String : Any], block : @escaping WSBlock){
        kprint(items: "----------- Edit Profile ----------")
        let relPath = "editProfile"
        uploadImage(relPath: relPath, img: image, param: param, comress: 0.25, headerParam: nil, block: block, progress: nil)
    }
    
    func logOutUser(block: @escaping WSBlock){
        let relPath = "logout"
        _ = postRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
}

// MARK:- Home WEB CALL
extension KPWebCall {
    func getBookings(param : [String: Any], block: @escaping WSBlock){
        kprint(items: "------------ Bookings -------------")
        //old
      //  let relPath = "getDriverBookings"
        //new
        let relPath = "getBarberBookings"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getCountryList(param : [String: Any], block: @escaping WSBlock){
        kprint(items: "------------ Bookings -------------")
        //old
      //  let relPath = "getDriverBookings"
        //new
        let relPath = "getCountries"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    func getReviews(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "------------ Reviews ----------------")
        let relPath = "getReview"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getOrderReview(param: [String: Any], block: @escaping WSBlock){
        kprint(items: "------------ Get Order Review --------")
        let relPath = "getOrderReview"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getOrders(param: [String : Any], block: @escaping WSBlock){
        kprint(items: "----------- Get Orders ---------")
        let relPath = "getBarberPaymentHistory"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getCancelReason(block : @escaping WSBlock){
        kprint(items: "--------- Cancel Reason ----------")
        let relPath = "cancelReasons"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func cancelOrder(param: [String: Any], block: @escaping WSBlock){
        let relPath = "cancelOrder"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getDirectionLocation(param : [String: Any], block : @escaping WSBlock){
        kprint(items: "--------- Get UserLocation ----------")
        let relPath = "mapLocationDriver"
        
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getRevenueData(param: [String : Any], block: @escaping WSBlock){
        kprint(items: "--------- Total Revenue -------")
        
        let relPath = "revenueFilterMap"
        
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getDriverRevenue(param : [String : Any], block : @escaping WSBlock){
        kprint(items: "---------- Get Driver Revenue Details -------------")
        
        let relPath = "totalRevenueOfBarber"
        
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func orderCompletedByDriver(param :[String : Any], block : @escaping WSBlock){
        kprint(items: "---------- Order Completed by Driver")
        let relPath = "orderComplete"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func updatedLocation(param : [String : Any], block : @escaping WSBlock){
        kprint(items: "------------ Updated Location--------")
        let relPath = "updateLatestLocation"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getNotification(block : @escaping WSBlock){
        let relPath = "getNotification"
        
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func addDeviceToken(param:[String : Any], block: @escaping WSBlock){
        let relPath = "addDeviceIdAndToken"
        
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func readAllNotification(param: [String:Any],block: @escaping WSBlock){
        let relPath = "read_notification"
        
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func getTermsPolicy(param : [String : Any], block : @escaping WSBlock){
        let relPath = "getTermsPolicy"
        
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
}

//MARK:- New API's
extension KPWebCall{
    func getServices(param: [String:Any], block: @escaping WSBlock){
        kprint(items: "------------ Get Services -----------")
        let relPath = "getServices"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addServices(param: [String:Any], block: @escaping WSBlock){
        kprint(items: "----------- Add Services ---------")
        let relpath = "addBarberService"
        _ = postRequest(relPath: relpath, param: param, headerParam: nil, block: block)
    }
    
    func getTimes(param: [String:Any], block: @escaping WSBlock){
        kprint(items: "------------ Get Times ---------")
        let relPath  = "getTimes"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addSlots(param: [String:Any], block: @escaping WSBlock){
        kprint(items: "------------ Add Slots ---------")
        let relPath = "addBarberTime"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addRadius(param: [String:Any], block : @escaping WSBlock){
        kprint(items: "-------------- Add Radius -----------")
        let relPath = "driverSelectRadius"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getDriverData(param: [String:Any], block : @escaping WSBlock){
        kprint(items: "------------- Get Driver Profile -------------")
        let relPath = "getDriverProfile"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }

    func updateTerms(param: [String: Any], block : @escaping WSBlock){
        kprint(items: "------------- Update Terms and Condition ---------")
        let relPath = "updateTermsPolicy"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func barberAvailblity(param: [String:Any], block : @escaping WSBlock){
        kprint(items: "----------------- Barber Availblity-------------")
        let relPath = "barberOnOff"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getAddedServices(block: @escaping WSBlock){
        kprint(items: "--------------- Added Services ----------------")
        let relPath = "getBarberService"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, block: block)
    }
    
    func deleteServices(param: [String:Any], block: @escaping WSBlock){
        kprint(items: "------------ Delete Services -----------")
        let relPath = "deleteBarberService"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func addPortfolio(param: [String:Any],imgs : [UIImage?], block : @escaping WSBlock){
        kprint(items: "------------ Add Portfolio-----------")
        let relPath = "addPortfolioes"
        uploadMultipleImgNew(relPath: relPath, imgs: imgs, headerParam: nil, block: block, progress: nil)
    }
    
    func getPortfolio(param: [String:Any], block : @escaping WSBlock){
        kprint(items: "----------- Get Portfolio -----------")
        let relPath = "getPortfolio"
        _ = getRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func deletePortfolio(param: [String:Any], block: @escaping WSBlock){
        kprint(items: "------------ Remove Portfolio ----------")
        let relPath = "removePortfolio"
        _ = postRequest(relPath: relPath, param: param, headerParam: nil, block: block)
    }
    
    func getState(block : @escaping WSBlock){
        kprint(items: "----------- Get State --------------")
        let countryID = _userDefault.value(forKey: "countryID")
        let relPath = "getStates?country_id=\(countryID!)"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, timeout: nil, block: block)
    }
    
    func getCities(block: @escaping WSBlock){
        kprint(items: "----------- Get State --------------")
        let countryID = _userDefault.value(forKey: "countryID")
        let relPath = "getCities?country_id=\(countryID!)"
        _ = getRequest(relPath: relPath, param: nil, headerParam: nil, timeout: nil, block: block)
    }
    
    func addBarberProfile(param: [String : Any],imgs: [UIImage],keys: [String], block : @escaping WSBlock){
        kprint(items: "---------- Register Barber ----------")
        let relPath = "addBarberProfile"
        //uploadMultipleImages(relPath: relPath, imgs: imgs, param: param, headerParam: nil, block: block, progress: nil)
        uploadMultipleImgNewOne(relPath: relPath,param: param, imgs: imgs, headerParam: nil, keys: keys, block: block, progress: nil)
    }
}
