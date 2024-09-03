//
//  ChatRoom.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct ChatRoom: Codable {
    let id: String
    var enabled: Bool
    let createDate: Date
    var updateDate: Date
    let userId: String
    let postUserId: String
    let userNickname: String
    let postUserNickname: String
    let userProfileImage: String
    let postUserProfileImage: String
    var userEnabled: Bool
    var postUserEnabled: Bool
    var userNotification: Bool
    var postUserNotification: Bool
    let userLocation: Location
    let postUserLocation: Location
    var messages: [Message]
    let postId: String
    let postImage: String?
    let postTitle: String
    var postStatus: PostStatus
    var hasLeavePlan: Bool
    var hasGetBackPlan: Bool
    var preferredPlace: Location?
}
