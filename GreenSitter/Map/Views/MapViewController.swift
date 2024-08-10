//
//  MapViewController.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/9/24.
//

import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController {

    let locationManager = CLLocationManager()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        view.addSubview(mapView)

        setupMapUI(with: Post.samplePosts)  // 나중에 실제 서버 데이터로 변경

//        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        locationManager.requestLocation()
    }
    
    // Post 객체 배열을 사용하여 지도에 마커 및 오버레이 추가
    func setupMapUI(with posts: [Post]) {
        for post in posts {
            guard let latitude = post.location?.latitude,
                  let longitude = post.location?.longitude else { continue }
            
            let circleCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let randomOffset = generateRandomOffset(for: circleCenter, radius: 500)
            let randomCenter = CLLocationCoordinate2D(
                latitude: circleCenter.latitude + randomOffset.latitudeDelta,
                longitude: circleCenter.longitude + randomOffset.longitudeDelta
            )
            
            let circle = MKCircle(center: randomCenter, radius: 500)
            mapView.addOverlay(circle)  // MKOverlayRenderer 메소드 호출
            
            // 원래의 circleCenter 위치에 마커 추가 (테스트 용)
            let originalMarker = MKPointAnnotation()
            originalMarker.coordinate = circleCenter
            originalMarker.title = "실제 위치: \(post.postTitle)"
            
            // Release 버전에서는 randomcenter 만 사용
            let randomCenterMarker = MKPointAnnotation()
            randomCenterMarker.coordinate = randomCenter
            randomCenterMarker.title = post.postTitle
            randomCenterMarker.subtitle = post.postBody
            
            mapView.addAnnotation(originalMarker)
            mapView.addAnnotation(randomCenterMarker)
        }
    }
    
    
    // 실제 위치(center) 기준으로 반경 내의 무작위 좌표를 새로운 중심점으로 설정
    func generateRandomOffset(for center: CLLocationCoordinate2D, radius: Double) -> (latitudeDelta: Double, longitudeDelta: Double) {
        let earthRadius: Double = 6378137 // meters
        let dLat = (radius / earthRadius) * (180 / .pi)
        let dLong = dLat / cos(center.latitude * .pi / 180)
        
        let randomLatDelta = Double.random(in: -dLat...dLat)
        let randomLongDelta = Double.random(in: -dLong...dLong)
        
        return (latitudeDelta: randomLatDelta, longitudeDelta: randomLongDelta)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // MARK: - MKMAPVIEW DELEGATE

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "mapAnnotation"
        
        if annotation is MKPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
    
    // 어노테이션 선택 시 카메라 위치 이동
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationCoordinate = view.annotation?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: annotationCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.3)
            circleRenderer.strokeColor = UIColor.red
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    

}


extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: - CLLOCATION MANAGER DELEGATE
    
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
//            showToast(withDuration: 1, delay: 4)
        default:
            print("GPS: Default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myLocation = locations.first {
            let latitude = myLocation.coordinate.latitude
            let longitude = myLocation.coordinate.longitude
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
}




class PinDetailViewController: UIViewController {
    let pin: Location
    
    init(pin: Location) {
        self.pin = pin
        super.init(nibName: nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Detail"
    }
}
