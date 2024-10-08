//
//  MapViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/13/24.
//

import CoreLocation
import Foundation
import MapKit

enum LocationAuthorizationStatus {
    case authorized
    case denied
    case restrictedOrNotDetermined
}

// MARK: - 사용자의 현재 위치 정보 가져오기, 위치 권한 관리

class MapViewModel: NSObject, ObservableObject {
    @Published var currentLocation: Location?   // 사용자의 현재 위치 정보 (위도, 경도, '주소')
    @Published var isLocationAuthorized: LocationAuthorizationStatus = .restrictedOrNotDetermined   // 위치 권한 허용 여부
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        print("Location Auth: \(locationManager.authorizationStatus)")
    }
    
    func checkLocationAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation() // 사용자 현재 위치 보고 시작해서 delegate 에게 알리기
    }
    
    // Kakao API 사용해서, 행정동명 주소 업데이트
    private func updateLocation(with location: CLLocation) {
        self.currentLocation = Location(
            locationId: UUID().uuidString, enabled: true,
            createDate: Date(),
            updateDate: Date(),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        KakaoAPIService.shared.fetchRegionInfo(for: self.currentLocation!) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedLocation):
                    self?.currentLocation?.address = updatedLocation.address
                    //self?.currentLocation = updatedLocation
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
        let defaultLocation = Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date())
        self.currentLocation = defaultLocation
        print("Using default location: \(defaultLocation)")
    }
}


// MARK: - CLLOCATION MANAGER DELEGATE

extension MapViewModel: CLLocationManagerDelegate {
    
    // 위치 권한 여부에 따른 처리
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.isLocationAuthorized = .authorized
                self.startUpdatingLocation()
            case .restricted, .notDetermined:
                self.isLocationAuthorized = .restrictedOrNotDetermined
                print("isLocationAuthorized: restricted or notDetermined")
                self.useDefaultLocation()
            case .denied:
                self.isLocationAuthorized = .denied
                self.useDefaultLocation()
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("DidUpdateLocations called with location: \(location.coordinate.latitude), \(location.coordinate.longitude)")

            updateLocation(with: location)  // 위치 정보를 currentLocation에 저장
            
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        useDefaultLocation()
    }
}
