//
//  User.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct User: Codable {
    var id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    var profileImage: String
    var nickname: String
    var location: Location
    let platform: String
    var levelPoint: Level
    var exp: Int
    var aboutMe: String
    let chatNotification: Bool
//    var isChatRoom: Bool
    
    mutating func updateExp(by expChange: Int) {
        //경험치 업데이트
        exp += expChange
        
        while exp >= 100 {
            let extraExp = exp - 100
            exp = extraExp
            levelPoint = levelPoint.nextLevel()
        } 
        
        while exp < 0 {
            levelPoint = levelPoint.previousLevel()
        }
    }
}

extension User {
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Ensure the date format matches your Firestore settings
        if let data = try? encoder.encode(self) {
            return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
        }
        return [:]
    }
}
