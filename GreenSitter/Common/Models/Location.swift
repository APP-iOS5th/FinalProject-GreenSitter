//
//  Location.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Location: Codable {
    let locationId: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let exactLongitude: Double
    let exactLatitude: Double
    let optionLongitude: Double?
    let optionLatitude: Double?
}
