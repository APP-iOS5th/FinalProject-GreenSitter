//
//  SampleChatData.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/8/24.
//

import Foundation
import UIKit

struct SampleChatData {
    static let chatRooms: [ChatRoom] = [
        ChatRoom(
            id: "150e8400-e29b-41d4-a716-446655440001",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            userId: "250e8400-e29b-41d4-a716-446655440001",
            postUserId: "250e8400-e29b-41d4-a716-446655440002",
            userNickname: "Owner1",
            postUserNickname: "Sitter1",
            userProfileImage: "https://picsum.photos/300",
            postUserProfileImage: "https://picsum.photos/300",
            userEnabled: true,
            postUserEnabled: true,
            userNotification: true,
            postUserNotification: true,
            userLocation: Location.sampleLocation
            ,
            postUserLocation: Location.seoulLocation
            ,
            messages: [
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440001",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440001",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440002",
                    isRead: true,
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
                    isRead: false,
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
            userId: "250e8400-e29b-41d4-a716-446655440001",
            postUserId: "250e8400-e29b-41d4-a716-446655440003",
            userNickname: "Owner2",
            postUserNickname: "Sitter2",
            userProfileImage: "https://picsum.photos/300",
            postUserProfileImage: "https://picsum.photos/300",
            userEnabled: true,
            postUserEnabled: true,
            userNotification: false,
            postUserNotification: false,
            userLocation: Location.sampleLocation
            ,
            postUserLocation: Location.sampleLocation
            ,
            messages: [
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440003",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440001",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440003",
                    isRead: true,
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
                    isRead: true,
                    messageType: .plan,
                    text: nil,
                    image: nil,
                    plan: Plan(planId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), planDate: Date(), planPlace: nil, contract: nil, ownerNotification: true, sitterNotification: true, isAccepted: true)
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
            userId: "250e8400-e29b-41d4-a716-446655440004",
            postUserId: "250e8400-e29b-41d4-a716-446655440001",
            userNickname: "Owner3",
            postUserNickname: "Sitter3",
            userProfileImage: "https://picsum.photos/300",
            postUserProfileImage: "https://picsum.photos/300",
            userEnabled: true,
            postUserEnabled: true,
            userNotification: true,
            postUserNotification: true,
            userLocation: Location.sampleLocation
            ,
            postUserLocation: Location.sampleLocation
            ,
            messages: [
                Message(
                    id: "350e8400-e29b-41d4-a716-446655440005",
                    enabled: true,
                    createDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                    updateDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
                    senderUserId: "250e8400-e29b-41d4-a716-446655440004",
                    receiverUserId: "250e8400-e29b-41d4-a716-446655440001",
                    isRead: false,
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
    
    static let exampleUsers = [
        User(
            id: "250e8400-e29b-41d4-a716-446655440001",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            profileImage: "https://picsum.photos/300",
            nickname: "JohnDoe",
            location: Location.seoulLocation,
            platform: "apple",
            levelPoint: 1,
            aboutMe: "A passionate developer with a love for Swift and iOS.",
            chatNotification: true
        ),
        User(
            id: "250e8400-e29b-41d4-a716-446655440002",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            profileImage: "https://picsum.photos/300",
            nickname: "JaneDoe",
            location: Location.seoulLocation,
            platform: "apple",
            levelPoint: 7,
            aboutMe: "A tech enthusiast who loves exploring new technologies.",
            chatNotification: false
        ),
        User(
            id: "250e8400-e29b-41d4-a716-446655440003",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            profileImage: "https://picsum.photos/300",
            nickname: "AliceSmith",
            location: Location.sampleLocation,
            platform: "apple",
            levelPoint: 12,
            aboutMe: "A digital nomad traveling the world while working remotely.",
            chatNotification: true
        )
    ]
    
    static let examplePosts = [
        Post(
            id: "40e8400-e29b-41d4-a716-446655440001",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            userId: "250e8400-e29b-41d4-a716-446655440001",
            profileImage: "https://picsum.photos/300",
            nickname: "JaneDoe",
            userLocation: Location.sampleLocation,
            userNotification: false,
            postType: .offeringToSitter,
            postTitle: "offering for a pet sitter",
            postBody: "offering for a responsible pet sitter to take care of my dog while I'm away.",
            postImages: [
                "https://picsum.photos/300",
                "https://picsum.photos/300"
            ],
            postStatus: .beforeTrade,
            location: Location.sampleLocation
        ),
        Post(
            id: "40e8400-e29b-41d4-a716-446655440002",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            userId: "250e8400-e29b-41d4-a716-446655440002",
            profileImage: "https://picsum.photos/300",
            nickname: "AliceSmith",
            userLocation: Location.sampleLocation,
            userNotification: true,
            postType: .offeringToSitter,
            postTitle: "Offering a pet sitting service",
            postBody: "Offering professional pet sitting services. Experienced and reliable.",
            postImages: [
                "https://picsum.photos/300",
                "https://picsum.photos/300"
            ],
            postStatus: .inTrade,
            location: Location.sampleLocation
        ),
        Post(
            id: "40e8400-e29b-41d4-a716-446655440003",
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            userId: "250e8400-e29b-41d4-a716-446655440003",
            profileImage: "https://picsum.photos/300",
            nickname: "AliceSmith",
            userLocation: Location.sampleLocation,
            userNotification: true,
            postType: .lookingForSitter,
            postTitle: "Need a pet sitter for the weekend",
            postBody: "Looking for someone to take care of my cat over the weekend. Please contact me if interested.",
            postImages: [
                "https://picsum.photos/300",
                "https://picsum.photos/300"
            ],
            postStatus: .completedTrade,
            location: Location.sampleLocation
        )
    ]
}

