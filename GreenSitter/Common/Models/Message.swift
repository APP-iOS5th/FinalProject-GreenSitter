//
//  Message.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Message: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let senderUserId: String
    let receiverUserId: String
    var isRead: Bool
    let messageType: MessageType
    let text: String?
    let image: [String]?
    let plan: Plan?
}

enum MessageType: String, Codable {
    case text, image, plan
}
