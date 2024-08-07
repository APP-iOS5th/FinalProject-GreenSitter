//
//  ChatRoom.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct ChatRoom: Codable {
    let id: UUID
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let ownerId: UUID
    let sitterId: UUID
    let ownerNickname: String
    let sitterNickname: String
    let ownerProfileImage: String
    let sitterProfileImage: String
    let ownerStatus: Bool
    let sitterStatus: Bool
    let messages: [Message]
    let postId: UUID
    let postImage: String
    let postTitle: String
    let postStatus: PostStatus
}
