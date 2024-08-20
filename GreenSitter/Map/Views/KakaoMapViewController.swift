////
////  MapViewController.swift
////  GreenSitter
////
////  Created by Yungui Lee on 8/7/24.
////
//
//import CoreLocation
//import UIKit
//import KakaoMapsSDK
//
//class KakaoMapViewController: UIViewController, MapControllerDelegate {
//    
//    var mapContainer: KMViewContainer?  // 카카오 맵 SDK에서 지도를 표시하기 위해 사용하는 UIView
//    var mapController: KMController?    // SDK의 인증 및 엔진과의 연결을 관리
//    var mapView: KakaoMap?
//    var _observerAdded: Bool
//    var _auth: Bool
//    var _appear: Bool
//    
//    var locationManager: CLLocationManager!
//    var latitude: CLLocationDegrees?
//    var longitude: CLLocationDegrees?
//    
//    var shapeLayer: ShapeLayer?
//    
//    init() {
//        self._observerAdded = false
//        self._auth = false
//        self._appear = false
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        self._observerAdded = false
//        self._auth = false
//        self._appear = false
//        super.init(coder: aDecoder)
//    }
//    
//    deinit {
//        mapController?.pauseEngine()
//        mapController?.resetEngine()
//        
//        print("deinit")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // KMViewContainer를 생성하고 view에 추가
//        mapContainer = KMViewContainer(frame: self.view.bounds)
//        if let mapContainer = mapContainer {
//            self.view.addSubview(mapContainer)
//        }
//        
//        // KMController 생성
//        if let mapContainer = mapContainer {
//            mapController = KMController(viewContainer: mapContainer)
//            mapController?.delegate = self
//            mapController?.prepareEngine() // 엔진 초기화. 엔진 내부 객체 생성 및 초기화가 진행된다.
//        }
//        
//        // Location Manager Delegate
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
//        
//        if let location = locationManager.location {
//            latitude = location.coordinate.latitude
//            longitude = location.coordinate.longitude
//        }
//
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
////        super.viewWillAppear(animated)
//        addObservers()
//        _appear = true
//        
//        if mapController?.isEngineActive == false {
//            mapController?.activateEngine()
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
////        super.viewDidAppear(animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
////        super.viewWillDisappear(animated)
//        _appear = false
//        mapController?.pauseEngine()  // 렌더링 중지.
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
////        super.viewDidDisappear(animated)
//        removeObservers()
//        mapController?.resetEngine()  // 엔진 정지. 추가되었던 ViewBase들이 삭제된다.
//    }
//    
//    // 인증 실패시 호출.
//    func authenticationFailed(_ errorCode: Int, desc: String) {
//        print("error code: \(errorCode)")
//        print("desc: \(desc)")
//        _auth = false
//        switch errorCode {
//        case 400:
//            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
//            break;
//        case 401:
//            showToast(self.view, message: "지도 종료(API인증 키 오류)")
//            break;
//        case 403:
//            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
//            break;
//        case 429:
//            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
//            break;
//        case 499:
//            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
//            
//            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                print("retry auth...")
//                
//                self.mapController?.prepareEngine()
//            }
//            break;
//        default:
//            break;
//        }
//    }
//    
//    func addViews() {
//        //여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
//        let defaultPosition: MapPoint = MapPoint(longitude: 126.9779, latitude: 37.5663)    // 서울 시청을 default position
//        //지도(KakaoMap)를 그리기 위한 viewInfo를 생성
//        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 15)    // 줌 레벨 15로 설정
//        
//        //KakaoMap 추가.
//        mapController?.addView(mapviewInfo)
//    }
//    
//    
//    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
//    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
//        print("View \(viewName) with info \(viewInfoName) added successfully.")
//        
//        // KakaoMap 객체 가져오기
//        mapView = mapController?.getView(viewName) as? KakaoMap
//        
//        guard let mapView else {
//            print("MapView is nil")
//            return
//        }
//
//        // 뷰 add 도중에 resize 이벤트가 발생한 경우 이벤트를 받지 못했을 수 있음. 원하는 뷰 사이즈로 재조정.
//        mapView.viewRect = mapContainer!.bounds
//        
//        // Shape Layer 생성
//        createShapeLayer(mapView)
//        
//        // Polygon Style Set 생성
//        createPolygonStyleSet(mapView)
//        
//        
//        createPolygonShape()
//        
//        // 초기 위치가 있다면 지도 위치 업데이트
//        updateMapPosition()
//    }
//    
//    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
//    func addViewFailed(_ viewName: String, viewInfoName: String) {
//        print("Failed to add view \(viewName) with info \(viewInfoName).")
//    }
//    
//    // Shape Layer 생성 함수
//    func createShapeLayer(_ mapView: KakaoMap) {
//        let manager = mapView.getShapeManager()
//
//        // 레이어의 이름과 렌더링 우선순위를 지정하여 ShapeLayer를 생성한다.
//        // 생성된 Layer가 리턴된다.
//        shapeLayer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001, passType: .route)
//        shapeLayer?.visible = true // 레이어를 보이도록 설정
//        print("ShapeLayer created and set to visible.")
//    }
//    
//    // Polygon Style Set 생성 함수
//    func createPolygonStyleSet(_ mapView: KakaoMap) {
//        let manager = mapView.getShapeManager()
//
//        // 레벨별 스타일을 생성.
//        let sitterShapeStyleLevel = PerLevelPolygonStyle(color: UIColor(.dominent), strokeWidth: 1, strokeColor: UIColor(.separatorsOpaque), level: 0)
//        let ownerShapeStyleLevel = PerLevelPolygonStyle(color: UIColor(.complementary), strokeWidth: 1, strokeColor: UIColor(.separatorsOpaque), level: 0)
//        
//        // 각 레벨별 스타일로 구성된 2개의 Polygon Style
//        let sitterShapeStyle = PolygonStyle(styles: [sitterShapeStyleLevel])
//        let ownerShapeStyle = PolygonStyle(styles: [ownerShapeStyleLevel])
//        
//        // PolygonStyle을 PolygonStyleSet에 추가.
//        let shapeStyleSet = PolygonStyleSet(styleSetID: "shapeStyleSet", styles: [sitterShapeStyle, ownerShapeStyle])
//        print("PolygonStyleSet created: \(shapeStyleSet)")
//        manager.addPolygonStyleSet(shapeStyleSet)
//    }
//    
//    func createPolygonShape() {
//        guard let layer = shapeLayer else {
//            print("ShapeLayer is not initialized.")
//            return
//        }
//         
//        // 첫 번째 PolygonShape 생성
//        let options1 = PolygonShapeOptions(shapeID: "CircleShape1", styleID: "shapeStyleSet", zOrder: 1)
//        let circlePoints1: [CGPoint] = Primitives.getCirclePoints(radius: 500, numPoints: 36, cw: true) // 500m 반지름
//        let polygon1 = Polygon(exteriorRing: circlePoints1, hole: nil, styleIndex: 0)
//        options1.polygons.append(polygon1)
//        
//        // basePosition을 500m 반경 내 임의의 지점으로 설정
//        let randomPosition1 = randomLocation(from: CLLocationCoordinate2D(latitude: 37.903, longitude: 127.06), within: 500)
//        options1.basePosition = MapPoint(longitude: randomPosition1.longitude, latitude: randomPosition1.latitude)
//
//        let shape1 = layer.addPolygonShape(options1) { shape in
//            if let shape = shape {
//                shape.show()
//                print("PolygonShape1 isShow: \(shape.isShow)")
//            }
//        }
//
//        // 두 번째 PolygonShape 생성
//        let options2 = PolygonShapeOptions(shapeID: "CircleShape2", styleID: "shapeStyleSet", zOrder: 1)
//        let circlePoints2: [CGPoint] = Primitives.getCirclePoints(radius: 500, numPoints: 36, cw: true) // 500m 반지름
//        let polygon2 = Polygon(exteriorRing: circlePoints2, hole: nil, styleIndex: 1)
//        options2.polygons.append(polygon2)
//        
//        // basePosition을 500m 반경 내 임의의 지점으로 설정
//        let randomPosition2 = randomLocation(from: CLLocationCoordinate2D(latitude: 37.903, longitude: 127.06), within: 500)
//        options2.basePosition = MapPoint(longitude: randomPosition2.longitude, latitude: randomPosition2.latitude)
//
//        let shape2 = layer.addPolygonShape(options2) { shape in
//            if let shape = shape {
//                shape.show()
//                print("PolygonShape2 isShow: \(shape.isShow)")
//            }
//        }
//        
//        // 모든 PolygonShape를 보이도록 설정
//        layer.showAllPolygonShapes()
//    }
//
//    // 임의의 위치를 생성하는 함수
//    func randomLocation(from location: CLLocationCoordinate2D, within radius: Double) -> CLLocationCoordinate2D {
//        let distance = Double.random(in: 0...radius)
//        let bearing = Double.random(in: 0..<360)
//        let earthRadius = 6371000.0
//        let bearingRad = bearing * .pi / 180
//        let lat1 = location.latitude * .pi / 180
//        let lon1 = location.longitude * .pi / 180
//        let lat2 = asin(sin(lat1) * cos(distance / earthRadius) + cos(lat1) * sin(distance / earthRadius) * cos(bearingRad))
//        let lon2 = lon1 + atan2(sin(bearingRad) * sin(distance / earthRadius) * cos(lat1), cos(distance / earthRadius) - sin(lat1) * sin(lat2))
//        let newLat = lat2 * 180 / .pi
//        let newLon = lon2 * 180 / .pi
//        return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
//    }
//
//    func focusOnPolygon(_ shape: PolygonShape) {
//        let basePosition = shape.basePosition
//        guard let mapView else {
//            return
//        }
//        // 카메라를 터치된 PolygonShape의 중심으로 이동
//        let cameraUpdate = CameraUpdate.make(target: basePosition, zoomLevel: 15, mapView: mapView)
//        mapView.moveCamera(cameraUpdate)
//        print("Polygon centered.")
//    }
//
//    
//    func updateMapPosition() {
//        guard let latitude = latitude, let longitude = longitude, let mapView = mapView else {
//            print("Latitude, Longitude or mapView is not initialized.")
//            return
//        }
//        
//        let cameraUpdate = CameraUpdate.make(target: MapPoint(longitude: longitude, latitude: latitude), zoomLevel: 15, mapView: mapView)
//        mapView.moveCamera(cameraUpdate)
//        print("Updating map position to latitude: \(latitude), longitude: \(longitude)")
//    }
//
//    
//    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
//    func containerDidResized(_ size: CGSize) {
//        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
//        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
//    }
//    
//    func viewWillDestroyed(_ view: ViewBase) {
//        
//    }
//    
//    func addObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        
//        _observerAdded = true
//    }
//    
//    func removeObservers() {
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
//        
//        _observerAdded = false
//    }
//    
//    @objc func willResignActive() {
//        mapController?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
//    }
//    
//    @objc func didBecomeActive() {
//        mapController?.activateEngine() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
//    }
//    
//    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
//        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
//        toastLabel.backgroundColor = UIColor.black
//        toastLabel.textColor = UIColor.white
//        toastLabel.textAlignment = NSTextAlignment.center;
//        view.addSubview(toastLabel)
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        
//        UIView.animate(withDuration: 0.4,
//                       delay: duration - 0.4,
//                       options: UIView.AnimationOptions.curveEaseOut,
//                       animations: {
//            toastLabel.alpha = 0.0
//        },
//                       completion: { (finished) in
//            toastLabel.removeFromSuperview()
//        })
//    }
//    
//    
//    // MARK: - ToastMessage
//    
//    private func showToast(withDuration: Double, delay: Double) {
//        let toastLabelWidth: CGFloat = 380
//        let toastLabelHeight: CGFloat = 80
//        
//        // UIView 생성
//        let toastView = UIView(frame: CGRect(x: (self.view.frame.size.width - toastLabelWidth) / 2, y: 75, width: toastLabelWidth, height: toastLabelHeight))
//        toastView.backgroundColor = UIColor.white
//        toastView.alpha = 1.0
//        toastView.layer.cornerRadius = 25
//        toastView.clipsToBounds = true
//        toastView.layer.borderColor = UIColor.gray.cgColor
//        toastView.layer.borderWidth = 1
//        
//        // 쉐도우 설정
//        toastView.layer.shadowColor = UIColor.gray.cgColor
//        toastView.layer.shadowOpacity = 0.5 // 투명도
//        toastView.layer.shadowOffset = CGSize(width: 4, height: 4) // 그림자 위치
//        toastView.layer.shadowRadius = 10
//        
//        // UIImageView 생성 및 설정
//        let image = UIImageView(image: UIImage(named: "logo7"))
//        image.layer.cornerRadius = 25
//        image.contentMode = .scaleAspectFit
//        image.translatesAutoresizingMaskIntoConstraints = false
//        image.widthAnchor.constraint(equalToConstant: 50).isActive = true  // 이미지의 크기를 설정.
//        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        
//        // UIButton 생성
//        let toastButton = UIButton()
//        toastButton.titleLabel?.font = .systemFont(ofSize: 13)
//        toastButton.setTitle("설정", for: .normal)
//        toastButton.setTitleColor(.white, for: .normal)
//        toastButton.backgroundColor = UIColor(.dominent)
//        toastButton.layer.cornerRadius = 4
//        toastButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        toastButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        toastButton.addAction(UIAction { _ in
//            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
//                if UIApplication.shared.canOpenURL(appSettings) {
//                    UIApplication.shared.open(appSettings)
//                }
//            }
//        }, for: .touchUpInside)
//        
//        // UILabel 생성 및 설정
//        let labelOne = UILabel()
//        labelOne.text = "위치 권한이 필요한 기능입니다."
//        labelOne.textColor = .black
//        labelOne.font = UIFont.systemFont(ofSize: 15, weight: .bold)
//        labelOne.textAlignment = .left
//        labelOne.translatesAutoresizingMaskIntoConstraints = false
//        
//        let labelTwo = UILabel()
//        labelTwo.text = "위치 권한 설정 화면으로 이동합니다."
//        labelTwo.textColor = .black
//        labelTwo.font = UIFont.systemFont(ofSize: 12)
//        labelTwo.textAlignment = .left
//        labelTwo.translatesAutoresizingMaskIntoConstraints = false
//        
//        // StackView 생성 및 설정 (Vertical Stack)
//        let labelStackView = UIStackView(arrangedSubviews: [labelOne, labelTwo])
//        labelStackView.axis = .vertical
//        labelStackView.alignment = .leading
//        labelStackView.spacing = 5
//        labelStackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // StackView 생성 및 설정 (Horizontal Stack)
//        let mainStackView = UIStackView(arrangedSubviews: [image, labelStackView, toastButton])
//        mainStackView.axis = .horizontal
//        mainStackView.alignment = .center
//        mainStackView.spacing = 10
//        mainStackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        toastView.addSubview(mainStackView)
//        
//        // Auto Layout 설정
//        NSLayoutConstraint.activate([
//            mainStackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
//            mainStackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
//            mainStackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
//            mainStackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10)
//        ])
//        
//        self.view.addSubview(toastView)
//        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
//            toastView.alpha = 0.0
//        }, completion: {(isCompleted) in
//            toastView.removeFromSuperview()
//        })
//    }
//}
//
//extension KakaoMapViewController: CLLocationManagerDelegate {
//    
//    func getLocationUsagePermission() {
//        self.locationManager.requestWhenInUseAuthorization()
//    }
//    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            print("GPS 권한 설정됨")
//        case .restricted, .notDetermined:
//            print("GPS 권한 설정되지 않음")
//            getLocationUsagePermission()
//        case .denied:
//            print("GPS 권한 요청 거부됨")
//            getLocationUsagePermission()
//            showToast(withDuration: 1, delay: 4)
//        default:
//            print("GPS: Default")
//        }
//    }
//    
//     // MARK: - CLLocationManagerDelegate
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let myLocation = locations.first {
//            self.latitude = myLocation.coordinate.latitude
//            self.longitude = myLocation.coordinate.longitude
//            updateMapPosition()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Failed to find user's location: \(error.localizedDescription)")
//    }
//    
//}
//
//
//#Preview {
//    KakaoMapViewController()
//}
//
//
//
////        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
////        let geocoder = CLGeocoder()
////        let locale = Locale(identifier: "Ko-kr")
////        geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale) { (placemarks, error) in
////            if let address: [CLPlacemark] = placemarks {
////                if let country: String = address.last?.country {
////                    print(country)
////                }
////                if let administrativeArea: String = address.last?.administrativeArea {
////                    print(administrativeArea)   // 도시 (서울 특별시)
////                }
////                if let locality: String = address.last?.locality { print(locality) }    // 동, 구 (관악구)
////                if let name: String = address.last?.name { print(name) }    // 상세 주소 (남부순환로 ...)
////            }
////        }