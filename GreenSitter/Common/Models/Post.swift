//
//  Post.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Post: Codable, Identifiable {
    var id = UUID()
    let enabled: Bool
    var createDate = Date()
    var updateDate = Date()
    let userId: String
    let profileImage: String
    let nickname: String
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
        Post(enabled: true, userId: "", profileImage: "", nickname: "부리부리대마왕", postType: .offeringToSitter, postTitle: "대형 화분 주기적으로 관리해드려요!", postBody: "저는 뱅갈고무나무랑 여인초를 키우고 ...", postImages: [], postStatus: .beforeTrade, location: Location(enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.566, longitude: 126.97)),
        
        Post(enabled: true, userId: "", profileImage: "", nickname: "짱구", postType: .lookingForSitter, postTitle: "가족여행 갈 동안 화분 부탁드립니다.", postBody: "베란다에서 키우는 화분들인데 4박5일 집을 비울 예정...", postImages: [], postStatus: .completedTrade, location: Location(enabled: true, createDate: Date(), updateDate: Date(), latitude: 37.903, longitude: 127.06))
    ]
}
