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
    
    let latitude: Double?
    let longitude: Double?
    let address: String?
}

extension Location {
    static let seoulLocation = Location(enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.566, longitude: 126.97, address: "서울특별시 동작구 상도로")
    static let sampleLocation = Location(enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.903, longitude: 127.06, address: "경기도 동두천시 생연동")
}

