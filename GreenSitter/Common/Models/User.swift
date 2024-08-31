//
//  User.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct User: Codable {
    var id: String
    var enabled: Bool
    var createDate: Date
    var updateDate: Date
    var profileImage: String
    var nickname: String
    var location: Location
    var platform: String
    var levelPoint: Level
    var exp: Int
    var aboutMe: String
    var chatNotification: Bool
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
        var dict = [String: Any]()
        dict["id"] = id
        dict["enabled"] = enabled
        let dateFormatter = ISO8601DateFormatter()
        dict["createDate"] = dateFormatter.string(from: createDate) // Date를 ISO8601 문자열로 변환
        dict["updateDate"] = dateFormatter.string(from: updateDate) // Date를 ISO8601 문자열로 변환
        dict["profileImage"] = profileImage
        dict["nickname"] = nickname
        dict["location"] = location.toDictionary() // Location이 Codable로 되어 있다면 따로 메서드 필요
        dict["platform"] = platform
        dict["levelPoint"] = levelPoint.rawValue // enum의 경우 rawValue로 저장
        dict["exp"] = exp
        dict["aboutMe"] = aboutMe
        dict["chatNotification"] = chatNotification
        return dict
    }
}
extension User {
    func printUserDetails() {
        let userDict = self.toDictionary()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userDict, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("User Object as JSON: \(jsonString)")
            }
        } catch {
            print("Error converting user to JSON: \(error)")
        }
    }
}
