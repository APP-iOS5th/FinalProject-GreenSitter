//
//  LevelPoint.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct LevelPoint: Codable {
    let count: Int
}

enum Level: String, Codable {
    case low, medium, high
}
