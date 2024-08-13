//
//  ChatRoom.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct ChatRoom: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let ownerId: String
    let sitterId: String
    let ownerNickname: String
    let sitterNickname: String
    let ownerProfileImage: String
    let sitterProfileImage: String
    let ownerStatus: Bool
    let sitterStatus: Bool
    let messages: [Message]
    let postId: String
    let postImage: String
    let postTitle: String
    let postStatus: PostStatus
}
