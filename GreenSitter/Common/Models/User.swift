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
    let chatNotification: Bool
    var fcmToken: String? = nil
    
    

    mutating func updateExp(by expChange: Int) {
        //경험치 업데이트
        exp += expChange
        
        while exp >= 100 {
            let extraExp = exp - 100
            exp = extraExp
            levelPoint = levelPoint.nextLevel()
        } 
        
        // 레벨 다운 처리
           while exp < 0 {
               let expNeededForCurrentLevel = 100 // 각 레벨마다 필요한 경험치
               
               // 경험치 부족분 계산
               let expNeededForPreviousLevel = expNeededForCurrentLevel + exp
               exp = expNeededForPreviousLevel
               
               // 레벨 변경
               levelPoint = levelPoint.previousLevel()
               
               // 최하위 레벨에 도달한 경우
               if levelPoint == .rottenSeeds {
                   exp = 0
                   break
               }
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
