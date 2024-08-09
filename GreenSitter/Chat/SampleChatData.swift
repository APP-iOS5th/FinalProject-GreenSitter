//
//  SampleChatData.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/8/24.
//

import Foundation
import UIKit

// 주조색, 보조색
extension UIColor {
    static let appGreen = UIColor(red: 128/255, green: 188/255, blue: 86/255, alpha: 1.0)
    static let appYellow = UIColor(red: 248/255, green: 215/255, blue: 103/255, alpha: 1.0)
    static let appBrown = UIColor(red: 136/255, green: 111/255, blue: 101/255, alpha: 1.0)
}

struct SampleChatData {
    static let chatRooms: [ChatRoom] = [
        ChatRoom(
            id: UUID(uuidString: "150e8400-e29b-41d4-a716-446655440001")!,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440001")!,
            sitterId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440002")!,
            ownerNickname: "Owner1",
            sitterNickname: "Sitter1",
            ownerProfileImage: "https://picsum.photos/300",
            sitterProfileImage: "https://picsum.photos/300",
            ownerStatus: true,
            sitterStatus: true,
            notification: true,
            partnerLocation: nil,
            messages: [
                Message(
                    id: UUID(uuidString: "350e8400-e29b-41d4-a716-446655440001")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440001")!,
                    read: true,
                    messageType: .text,
                    text: "Hello!",
                    image: nil,
                    plan: nil
                ),
                Message(
                    id: UUID(uuidString: "350e8400-e29b-41d4-a716-446655440002")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440002")!,
                    read: false,
                    messageType: .image,
                    text: nil,
                    image: ["https://example.com/image3.jpg"],
                    plan: nil
                )
            ],
            postId: UUID(uuidString: "450e8400-e29b-41d4-a716-446655440001")!,
            postImage: "https://example.com/post1.jpg",
            postTitle: "Post Title 1",
            postStatus: .beforeTrade
        ),
        ChatRoom(
            id: UUID(uuidString: "150e8400-e29b-41d4-a716-446655440002")!,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440001")!,
            sitterId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440003")!,
            ownerNickname: "Owner2",
            sitterNickname: "Sitter2",
            ownerProfileImage: "https://picsum.photos/300",
            sitterProfileImage: "https://picsum.photos/300",
            ownerStatus: true,
            sitterStatus: true,
            notification: false,
            partnerLocation: nil,
            messages: [
                Message(
                    id: UUID(uuidString: "350e8400-e29b-41d4-a716-446655440003")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440001")!,
                    read: true,
                    messageType: .plan,
                    text: "Hello!",
                    image: nil,
                    plan: nil
                ),
                Message(
                    id: UUID(uuidString: "350e8400-e29b-41d4-a716-446655440004")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440003")!,
                    read: true,
                    messageType: .plan,
                    text: nil,
                    image: nil,
                    plan: Plan(planId: UUID(), enabled: true, createDate: Date(), updateDate: Date(), planDate: Date(), planPlace: nil, contract: nil, ownerNotification: true, sitterNotification: true, isAccepted: true)
                )
            ],
            postId: UUID(uuidString: "450e8400-e29b-41d4-a716-446655440002")!,
            postImage: "https://example.com/post2.jpg",
            postTitle: "Post Title 2",
            postStatus: .inTrade
        ),
        ChatRoom(
            id: UUID(uuidString: "150e8400-e29b-41d4-a716-446655440003")!,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440004")!,
            sitterId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440001")!,
            ownerNickname: "Owner3",
            sitterNickname: "Sitter3",
            ownerProfileImage: "https://picsum.photos/300",
            sitterProfileImage: "https://picsum.photos/300",
            ownerStatus: true,
            sitterStatus: true,
            notification: true,
            partnerLocation: nil,
            messages: [
                Message(
                    id: UUID(uuidString: "350e8400-e29b-41d4-a716-446655440005")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "250e8400-e29b-41d4-a716-446655440004")!,
                    read: false,
                    messageType: .text,
                    text: "See you later!",
                    image: nil,
                    plan: nil
                )
            ],
            postId: UUID(uuidString: "450e8400-e29b-41d4-a716-446655440003")!,
            postImage: "https://example.com/post3.jpg",
            postTitle: "Post Title 3",
            postStatus: .inTrade
        )
    ]
}

