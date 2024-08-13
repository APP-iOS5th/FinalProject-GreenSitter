//
//  Location.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation
import MapKit

// Location 클래스는 위치 정보만을 관리
struct Location: Codable, Identifiable {
    var id = UUID()
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    
    var latitude: Double
    var longitude: Double
    var placeName: String
    var address: String
    
    init(enabled: Bool, createDate: Date, updateDate: Date, latitude: Double? = nil, longitude: Double? = nil, placeName: String? = nil, address: String? = nil) {
        self.enabled = enabled
        self.createDate = createDate
        self.updateDate = updateDate
        
        // 기본값 설정: 위도와 경도가 nil일 경우 서울 시청으로 설정
        self.latitude = latitude ?? 37.566
        self.longitude = longitude ?? 126.97
        self.placeName = placeName ?? "서울특별시청"
        self.address = address ?? "서울 중구 세종대로"
    }
}


extension Location {
    static let seoulLocation = Location(enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.566, longitude: 126.97, address: "서울특별시 동작구 상도로")
    static let sampleLocation = Location(enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.903, longitude: 127.06, address: "경기도 동두천시 생연동")
}

