//
//  MapViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/13/24.
//

import CoreLocation
import Foundation
import MapKit

// MARK: - 사용자의 현재 위치 정보 가져오기, 위치 권한 관리

class MapViewModel: NSObject, ObservableObject {
    @Published var currentLocation: Location?   // 사용자의 현재 위치 정보 (위도, 경도, '주소')
    @Published var isLocationAuthorized: Bool = false   // 위치 권한 허용 여부
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation() // 사용자 현재 위치 보고 시작해서 delegate 에게 알리기
    }
    
//    func requestLocation() {
//        locationManager.requestLocation()
//    }
    
    // Kakao API 사용해서, 행정동명 주소 업데이트
    private func updateLocation(with location: CLLocation) {
        var currentLocation = Location(
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        KakaoAPIService.shared.fetchRegionInfo(for: currentLocation) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedLocation):
                    self?.currentLocation?.address = updatedLocation.address
                    print("Updated Address: \(updatedLocation.address)")
                case .failure(let error):
                    print("Error fetching region info: \(error)")
                    // API 실패 시 기본 default location으로 설정됨.
                }
            }
        }
    }
    
    
    // 위치 권한 거부 시 default position 으로 설정
    private func useDefaultLocation() {
        let defaultLocation = Location(enabled: true, createDate: Date(), updateDate: Date())
        self.currentLocation = defaultLocation
        print("Using default location: \(defaultLocation)")
    }
}


// MARK: - CLLOCATION MANAGER DELEGATE

extension MapViewModel: CLLocationManagerDelegate {
    
    // 위치 권한 여부에 따른 처리
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isLocationAuthorized = true
            startUpdatingLocation()
        case .restricted, .notDetermined:
            print("isLocationAuthorized: restriceted or notDetermined")
        case .denied:
            isLocationAuthorized = false
            useDefaultLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            updateLocation(with: location)  // 위치 정보를 currentLocation에 저장
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        useDefaultLocation()
    }
}
