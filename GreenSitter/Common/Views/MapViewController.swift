//
//  MapViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import CoreLocation
import UIKit
import KakaoMapsSDK

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class APISampleBaseViewController: UIViewController, MapControllerDelegate {
    
    var mapContainer: KMViewContainer?  // 카카오 맵 SDK에서 지도를 표시하기 위해 사용하는 UIView
    var mapController: KMController?    // SDK의 인증 및 엔진과의 연결을 관리
    var mapView: KakaoMap?
    var _observerAdded: Bool
    var _auth: Bool
    var _appear: Bool
    
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    init() {
        self._observerAdded = false
        self._auth = false
        self._appear = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self._observerAdded = false
        self._auth = false
        self._appear = false
        super.init(coder: aDecoder)
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // KMViewContainer를 생성하고 view에 추가
        mapContainer = KMViewContainer(frame: self.view.bounds)
        if let mapContainer = mapContainer {
            self.view.addSubview(mapContainer)
        }
        
        // KMController 생성
        if let mapContainer = mapContainer {
            mapController = KMController(viewContainer: mapContainer)
            mapController?.delegate = self
            mapController?.prepareEngine() // 엔진 초기화. 엔진 내부 객체 생성 및 초기화가 진행된다.
        }
        
        // Location Manager Delegate
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        if let location = locationManager.location {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
//        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
//        let geocoder = CLGeocoder()
//        let locale = Locale(identifier: "Ko-kr")
//        geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale) { (placemarks, error) in
//            if let address: [CLPlacemark] = placemarks {
//                if let country: String = address.last?.country {
//                    print(country)
//                }
//                if let administrativeArea: String = address.last?.administrativeArea {
//                    print(administrativeArea)   // 도시 (서울 특별시)
//                }
//                if let locality: String = address.last?.locality { print(locality) }    // 동, 구 (관악구)
//                if let name: String = address.last?.name { print(name) }    // 상세 주소 (남부순환로 ...)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        _appear = true
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mapController?.isEngineActive == true {
            addViews()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _appear = false
        mapController?.pauseEngine()  // 렌더링 중지.
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
        mapController?.resetEngine()  // 엔진 정지. 추가되었던 ViewBase들이 삭제된다.
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break;
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break;
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
    
    func addViews() {
        //여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        //지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
        
        //KakaoMap 추가.
        mapController?.addView(mapviewInfo)
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("View \(viewName) with info \(viewInfoName) added successfully.")
        
        // KakaoMap 객체 가져오기
        mapView = mapController?.getView(viewName) as? KakaoMap
        
        // 초기 위치가 있다면 지도 위치 업데이트
        updateMapPosition()
    }
    
    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed to add view \(viewName) with info \(viewInfoName).")
    }
    
    func updateMapPosition() {
        if mapView == nil {
            mapView = mapController?.getView("mapview") as? KakaoMap
        }
        
        if let latitude = latitude, let longitude = longitude, let mapView = mapView {
            print("Updating map position to latitude: \(latitude), longitude: \(longitude)") // Debug log
            let currentPosition = MapPoint(longitude: longitude, latitude: latitude)
            let cameraUpdate = CameraUpdate.make(
                target: currentPosition,
                zoomLevel: 15,
                rotation: 1.7,
                tilt: 0.0,
                mapView: mapView
            )
            mapView.moveCamera(cameraUpdate)
        }
    }
    
    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
    }
    
    func viewWillDestroyed(_ view: ViewBase) {
        
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = true
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        _observerAdded = false
    }
    
    @objc func willResignActive(){
        mapController?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
    }
    
    @objc func didBecomeActive(){
        mapController?.activateEngine() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
            toastLabel.alpha = 0.0
        },
                       completion: { (finished) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension APISampleBaseViewController: CLLocationManagerDelegate {
    
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            getLocationUsagePermission()
        default:
            print("GPS: Default")
        }
    }
    
     // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myLocation = locations.first {
            self.latitude = myLocation.coordinate.latitude
            self.longitude = myLocation.coordinate.longitude
            updateMapPosition()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
}
