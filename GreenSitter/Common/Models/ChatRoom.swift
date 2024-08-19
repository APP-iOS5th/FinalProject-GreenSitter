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
    let ownerId: String
    let sitterId: String
    let ownerNickname: String
    let sitterNickname: String
    let ownerProfileImage: String
    let sitterProfileImage: String
    var ownerEnabled: Bool
    var sitterEnabled: Bool
    var ownerNotification: Bool
    var sitterNotification: Bool
    let ownerLocation: Location
    let sitterLocation: Location
    var messages: [Message]
    let postId: String
    let postImage: String?
    let postTitle: String
    let postStatus: PostStatus
}
