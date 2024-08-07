//
//  Pin.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Pin: Codable {
    let pinId: UUID
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let pinType: PostType
    let postId: UUID
    let postTitle: String
    let userId: UUID
    let nickname: String
    let profileImage: String
}
