//
//  User.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct User: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let profileImage: String
    var nickname: String
    let location: Location?
    let platform: String
    let levelPoint: Level
    let aboutMe: String
}
