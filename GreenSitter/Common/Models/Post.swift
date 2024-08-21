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
    
    // user
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
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "부리부리대마왕", userLocation: Location.seoulLocation, userNotification: false, postType: .offeringToSitter, postTitle: "대형 화분 주기적으로 관리해드려요!", postBody: "저는 뱅갈고무나무랑 여인초를 키우고 ...", postImages: ["image1", "image2", "image3"], postStatus: .beforeTrade, location: Location.seoulLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "부리부리대마왕1", userLocation: Location.seoulLocation, userNotification: false, postType: .lookingForSitter, postTitle: "가족여행 갈 동안 화분 부탁드립니다.", postBody: "베란다에서 키우는 화분들인데 4박5일 집을 비울 예정...", postImages: ["image1", "image2"], postStatus: .inTrade, location: Location.sampleLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "부리부리대마왕2", userLocation: Location.seoulLocation, userNotification: false, postType: .lookingForSitter, postTitle: "작은 화분 돌봐드립니다", postBody: "작은 화분도 잘 돌볼 수 있어요...", postImages: ["image3"], postStatus: .beforeTrade, location: Location.seoulLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "식물박사", userLocation: Location.busanLocation, userNotification: false, postType: .offeringToSitter, postTitle: "식물 관리 전문가입니다.", postBody: "10년 이상의 경험을 바탕으로 모든 종류의 식물을 관리해드립니다.", postImages: ["image2", "image4"], postStatus: .inTrade, location: Location.busanLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "식물초보", userLocation: Location.daejeonLocation, userNotification: false, postType: .lookingForSitter, postTitle: "출장 동안 식물 관리 부탁드립니다.", postBody: "출장으로 인해 1주일 동안 집을 비울 예정입니다. 작은 화분 3개를 관리해주실 분을 찾습니다.", postImages: ["image1"], postStatus: .completedTrade, location: Location.daejeonLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "화분도사", userLocation: Location.seoulLocation, userNotification: false, postType: .offeringToSitter, postTitle: "화분 전문가의 관리 서비스 제공", postBody: "다양한 화분을 정기적으로 관리해드립니다. 상담 환영합니다.", postImages: ["image4"], postStatus: .inTrade, location: Location.seoulLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "화분도사2", userLocation: Location.incheonLocation, userNotification: false, postType: .lookingForSitter, postTitle: "베란다 화분 관리 부탁드립니다.", postBody: "휴가로 인해 2주 동안 자리를 비웁니다. 베란다에 있는 화분들을 돌봐주세요.", postImages: ["image2", "image3"], postStatus: .completedTrade, location: Location.incheonLocation),
        
        Post(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: "", profileImage: "profileIcon", nickname: "플랜트러버", userLocation: Location.seoulLocation, userNotification: false, postType: .offeringToSitter, postTitle: "다양한 식물의 건강한 성장을 도와드립니다.", postBody: "자주 출장 가시는 분들에게 적합한 맞춤형 식물 관리 서비스입니다.", postImages: ["image1", "image4"], postStatus: .inTrade, location: Location.seoulLocation)
    ]
}


