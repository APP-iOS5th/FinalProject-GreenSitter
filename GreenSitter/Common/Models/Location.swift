//
//  Location.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation
import MapKit

struct Location: Codable {
    let locationId: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    
    var latitude: Double
    var longitude: Double
    var placeName: String
    var address: String
    
    init(locationId: String, enabled: Bool, createDate: Date, updateDate: Date, latitude: Double? = nil, longitude: Double? = nil, placeName: String? = nil, address: String? = nil) {
        self.locationId = UUID().uuidString
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
    static let seoulLocation = Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.566, longitude: 126.97, address: "서울특별시 동작구 상도로")
    static let busanLocation = Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), latitude: 35.179, longitude: 129.075, address: "부산광역시 해운대구 우동")
    static let daejeonLocation = Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), latitude: 36.351, longitude: 127.385, address: "대전광역시 유성구 궁동")
    static let incheonLocation = Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.456, longitude: 126.705, address: "인천광역시 남동구 구월동")
    static let sampleLocation = Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.903, longitude: 127.06, address: "경기도 동두천시 생연동")
}


extension Location {
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Ensure the date format matches your Firestore settings
        if let data = try? encoder.encode(self) {
            return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
        }
        return [:]
    }
}
