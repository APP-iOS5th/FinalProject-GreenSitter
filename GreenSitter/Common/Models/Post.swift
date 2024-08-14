//
//  Post.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Post: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let userId: String
    let profileImage: String
    let nickname: String
    let userLocation: Location
    let userNotification: Bool
    let postType: PostType
    let postTitle: String
    let postBody: String
    let postImages: [String]?
    let postStatus: PostStatus
    let location: Location?
}

enum PostType: String, Codable {
    case lookingForSitter = "새싹 돌봐드립니다"
    case offeringToSitter = "새싹돌봄이 찾습니다"
}

enum PostStatus: String, Codable {
    case beforeTrade = "거래전"
    case inTrade = "거래중"
    case completedTrade = "거래완료"
}


extension Post {
    static let samplePosts: [Post] = [
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "", nickname: "부리부리대마왕", userLocation: Location.seoulLocation, userNotification: false, postType: .offeringToSitter, postTitle: "대형 화분 주기적으로 관리해드려요!", postBody: "저는 뱅갈고무나무랑 여인초를 키우고 ...", postImages: [], postStatus: .beforeTrade, location: Location.seoulLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "", nickname: "부리부리대마왕1", userLocation: Location.seoulLocation, userNotification: false, postType: .lookingForSitter, postTitle: "가족여행 갈 동안 화분 부탁드립니다.", postBody: "베란다에서 키우는 화분들인데 4박5일 집을 비울 예정...", postImages: [], postStatus: .completedTrade, location: Location.sampleLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "", nickname: "부리부리대마왕2", userLocation: Location.seoulLocation, userNotification: false, postType: .lookingForSitter, postTitle: "작은 화분 돌봐드립니다", postBody: "작은 화분도 잘 돌볼 수 있어요...", postImages: [], postStatus: .beforeTrade, location: Location.seoulLocation)
    ]
}
