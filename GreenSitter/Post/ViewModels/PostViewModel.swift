//
//  PostViewModel.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

import Foundation

class PostViewModel {
    private var firestoreManager = FirestoreManager()
    
    // 임시 데이터
    var user = SampleChatData.exampleUsers[0]
    var post = SampleChatData.examplePosts[2]
    
    var onChatButtonTapped: ((ChatRoom) -> Void)?

    // 채팅버튼 클릭 시 호출될 메서드
    func buttonTapped() async {
        guard let newChat = makeChat() else {
            print("Failed to create new chat")
            return
        }
        
        Task {
            do {
                // 채팅방 데이터 저장
                try await self.firestoreManager.saveChatRoom(newChat)
                print("Succeed to save chat room")
                
                if let onChatButtonTapped = self.onChatButtonTapped {
                    DispatchQueue.main.async {
                        onChatButtonTapped(newChat)
                    }
                } else {
                    print("onChatButtonTapped is not set")
                }
            } catch {
                print("Failed to save chat room: \(error.localizedDescription)")
                return
            }
        }
    }
        
    // ChatRoom 객체 생성
    func makeChat() -> ChatRoom? {
        // 사용자, 게시물 작성자의 아이디, 닉네임, 프로필 이미지, 채팅 알림 유무, 위치
        let ownerId: String
        let ownerNickname: String
        let ownerProfileImage: String
        let ownerNotification: Bool
        let ownerLocation: Location
        
        let sitterId: String
        let sitterNickname: String
        let sitterProfileImage: String
        let sitterNotification: Bool
        let sitterLocation: Location
        
//        if post.postType == .lookingForSitter {
//            ownerId = post?.userId ?? UUID().uuidString
//            ownerNickname = post?.nickname ?? ""
//            ownerProfileImage = post?.profileImage ?? ""
//            ownerNotification = post?.userNotification ?? true
//            ownerLocation = post?.userLocation ?? Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), exactLongitude: 1.0, exactLatitude: 1.0, optionLongitude: 1.0, optionLatitude: 1.0)
//            
//            sitterId = user?.id ?? UUID().uuidString
//            sitterNickname = user?.nickname ?? ""
//            sitterProfileImage = user?.profileImage ?? ""
//            sitterNotification = user?.chatNotification ?? true
//            sitterLocation = user?.location ?? Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), exactLongitude: 1.0, exactLatitude: 1.0, optionLongitude: 1.0, optionLatitude: 1.0)
//        } else {
//            ownerId = user?.id ?? UUID().uuidString
//            ownerNickname = user?.nickname ?? ""
//            ownerProfileImage = user?.profileImage ?? ""
//            ownerNotification = user?.chatNotification ?? true
//            ownerLocation = user?.location ?? Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), exactLongitude: 1.0, exactLatitude: 1.0, optionLongitude: 1.0, optionLatitude: 1.0)
//            
//            sitterId = post?.userId ?? UUID().uuidString
//            sitterNickname = post?.nickname ?? ""
//            sitterProfileImage = post?.profileImage ?? ""
//            sitterNotification = post?.userNotification ?? true
//            sitterLocation = post?.userLocation ?? Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), exactLongitude: 1.0, exactLatitude: 1.0, optionLongitude: 1.0, optionLatitude: 1.0)
//        }
//        
//        // 게시물 썸네일
//        guard let postThumbnail = post?.postImages?.first else {
//            return nil
//        }
//        
//        let newChat = ChatRoom(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), ownerId: ownerId, sitterId: sitterId, ownerNickname: ownerNickname, sitterNickname: sitterNickname, ownerProfileImage: ownerProfileImage, sitterProfileImage: sitterProfileImage, ownerStatus: false, sitterStatus: false, ownerNotification: ownerNotification, sitterNotification: sitterNotification, ownerLocation: ownerLocation, sitterLocation: sitterLocation, messages: [], postId: post?.id ?? UUID().uuidString, postImage: postThumbnail, postTitle: post?.postTitle ?? "", postStatus: post?.postStatus ?? .beforeTrade)
        
        if post.postType == .lookingForSitter {
            ownerId = post.userId
            ownerNickname = post.nickname
            ownerProfileImage = post.profileImage
            ownerNotification = post.userNotification
            ownerLocation = post.userLocation
            
            sitterId = user.id
            sitterNickname = user.nickname
            sitterProfileImage = user.profileImage
            sitterNotification = user.chatNotification
            sitterLocation = user.location
        } else {
            ownerId = user.id
            ownerNickname = user.nickname
            ownerProfileImage = user.profileImage
            ownerNotification = user.chatNotification
            ownerLocation = user.location
            
            sitterId = post.userId
            sitterNickname = post.nickname
            sitterProfileImage = post.profileImage
            sitterNotification = post.userNotification
            sitterLocation = post.userLocation
        }
        
        // 게시물 썸네일
        guard let postThumbnail = post.postImages?.first else {
            return nil
        }
        
        let newChat = ChatRoom(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), ownerId: ownerId, sitterId: sitterId, ownerNickname: ownerNickname, sitterNickname: sitterNickname, ownerProfileImage: ownerProfileImage, sitterProfileImage: sitterProfileImage, ownerEnabled: true, sitterEnabled: true, ownerNotification: ownerNotification, sitterNotification: sitterNotification, ownerLocation: ownerLocation, sitterLocation: sitterLocation, messages: [], postId: post.id, postImage: postThumbnail, postTitle: post.postTitle, postStatus: post.postStatus)
        
        return newChat
    }
    
}
