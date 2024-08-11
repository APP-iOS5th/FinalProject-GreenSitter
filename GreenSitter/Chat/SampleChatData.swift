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
            id: "150e8400-e29b-41d4-a716-446655440001",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: "250e8400-e29b-41d4-a716-446655440001",
            sitterId: "250e8400-e29b-41d4-a716-446655440002",
            ownerNickname: "Owner1",
            sitterNickname: "Sitter1",
            ownerProfileImage: "https://picsum.photos/300",
            sitterProfileImage: "https://picsum.photos/300",
            ownerStatus: true,
            sitterStatus: true,
            ownerNotification: true,
            sitterNotification: true,
            ownerLocation: nil,
            sitterLocation: nil,
            messages: [
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440001",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440001",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440002",
                    read: true,
                    messageType: .text,
                    text: "Hello!",
                    image: nil,
                    plan: nil
                ),
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440002",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440002",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440001",
                    read: false,
                    messageType: .image,
                    text: nil,
                    image: ["https://example.com/image3.jpg"],
                    plan: nil
                )
            ],
            postId: "450e8400-e29b-41d4-a716-446655440001",
            postImage: "https://example.com/post1.jpg",
            postTitle: "Post Title 1",
            postStatus: .beforeTrade
        ),
        ChatRoom(
            id: "150e8400-e29b-41d4-a716-446655440002",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: "250e8400-e29b-41d4-a716-446655440001",
            sitterId: "250e8400-e29b-41d4-a716-446655440003",
            ownerNickname: "Owner2",
            sitterNickname: "Sitter2",
            ownerProfileImage: "https://picsum.photos/300",
            sitterProfileImage: "https://picsum.photos/300",
            ownerStatus: true,
            sitterStatus: true,
            ownerNotification: false,
            sitterNotification: false,
            ownerLocation: nil,
            sitterLocation: nil,
            messages: [
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440003",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440001",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440003",
                    read: true,
                    messageType: .plan,
                    text: "Hello!",
                    image: nil,
                    plan: nil
                ),
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440004",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440003",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440001",
                    read: true,
                    messageType: .plan,
                    text: nil,
                    image: nil,
                    plan: Plan(planId: UUID(), enabled: true, createDate: Date(), updateDate: Date(), planDate: Date(), planPlace: nil, contract: nil, ownerNotification: true, sitterNotification: true, isAccepted: true)
                )
            ],
            postId: "450e8400-e29b-41d4-a716-446655440002",
            postImage: "https://example.com/post2.jpg",
            postTitle: "Post Title 2",
            postStatus: .inTrade
        ),
        ChatRoom(
            id: "150e8400-e29b-41d4-a716-446655440003",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: "250e8400-e29b-41d4-a716-446655440004",
            sitterId: "250e8400-e29b-41d4-a716-446655440001",
            ownerNickname: "Owner3",
            sitterNickname: "Sitter3",
            ownerProfileImage: "https://picsum.photos/300",
            sitterProfileImage: "https://picsum.photos/300",
            ownerStatus: true,
            sitterStatus: true,
            ownerNotification: true,
            sitterNotification: true,
            ownerLocation: nil,
            sitterLocation: nil,
            messages: [
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440005",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440004",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440001",
                    read: false,
                    messageType: .text,
                    text: "See you later!",
                    image: nil,
                    plan: nil
                )
            ],
            postId: "450e8400-e29b-41d4-a716-446655440003",
            postImage: "https://example.com/post3.jpg",
            postTitle: "Post Title 3",
            postStatus: .inTrade
        )
    ]
}

