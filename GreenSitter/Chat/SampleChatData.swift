//
//  SampleChatData.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/8/24.
//

import Foundation

struct SampleData {
    static let chatRooms: [ChatRoom] = [
        ChatRoom(
            id: UUID(uuidString: "1-1")!,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: UUID(uuidString: "2-1")!,
            sitterId: UUID(uuidString: "2-2")!,
            ownerNickname: "Owner1",
            sitterNickname: "Sitter1",
            ownerProfileImage: "https://example.com/image1.jpg",
            sitterProfileImage: "https://example.com/image2.jpg",
            ownerStatus: true,
            sitterStatus: true,
            messages: [
                Message(
                    id: UUID(uuidString: "3-1")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "2-1")!,
                    read: true,
                    messageType: .text,
                    text: "Hello!",
                    image: nil,
                    plan: nil
                ),
                Message(
                    id: UUID(uuidString: "3-2")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "2-2")!,
                    read: false,
                    messageType: .image,
                    text: nil,
                    image: ["https://example.com/image3.jpg"],
                    plan: nil
                )
            ],
            postId: UUID(uuidString: "4-1")!,
            postImage: "https://example.com/post1.jpg",
            postTitle: "Post Title 1",
            postStatus: .beforeTrade
        ),
        ChatRoom(
            id: UUID(uuidString: "1-2")!,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: UUID(uuidString: "2-1")!,
            sitterId: UUID(uuidString: "2-3")!,
            ownerNickname: "Owner2",
            sitterNickname: "Sitter2",
            ownerProfileImage: "https://example.com/image4.jpg",
            sitterProfileImage: "https://example.com/image5.jpg",
            ownerStatus: true,
            sitterStatus: true,
            messages: [
                Message(
                    id: UUID(uuidString: "3-3")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "2-1")!,
                    read: true,
                    messageType: .plan,
                    text: "Hello!",
                    image: nil,
                    plan: nil
                ),
                Message(
                    id: UUID(uuidString: "3-4")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "2-3")!,
                    read: true,
                    messageType: .plan,
                    text: nil,
                    image: nil,
                    plan: nil
                )
            ],
            postId: UUID(uuidString: "4-2")!,
            postImage: "https://example.com/post2.jpg",
            postTitle: "Post Title 2",
            postStatus: .inTrade
        ),
        ChatRoom(
            id: UUID(uuidString: "1-3")!,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            ownerId: UUID(uuidString: "2-4")!,
            sitterId: UUID(uuidString: "2-1")!,
            ownerNickname: "Owner3",
            sitterNickname: "Sitter3",
            ownerProfileImage: "https://example.com/image6.jpg",
            sitterProfileImage: "https://example.com/image7.jpg",
            ownerStatus: true,
            sitterStatus: true,
            messages: [
                Message(
                    id: UUID(uuidString: "3-5")!,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    userId: UUID(uuidString: "2-4")!,
                    read: false,
                    messageType: .text,
                    text: "See you later!",
                    image: nil,
                    plan: nil
                )
            ],
            postId: UUID(uuidString: "4-3")!,
            postImage: "https://example.com/post3.jpg",
            postTitle: "Post Title 3",
            postStatus: .inTrade
        )
    ]
}

