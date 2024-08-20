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
    func chatButtonTapped() async {
        guard let newChat = makeChat() else {
            print("Failed to create new chat")
            return
        }
        
        do {
            // 채팅방 데이터 저장
            try await self.firestoreManager.saveChatRoom(newChat)
            
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
    
    // ChatRoom 객체 생성
    func makeChat() -> ChatRoom? {
        
        // 게시물 썸네일
        guard let postThumbnail = post.postImages?.first else {
            return nil
        }
        
        // TODO: - messages는 하위 컬렉션으로 저장
        let newChat = ChatRoom(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: user.id, postUserId: post.userId, userNickname: user.nickname, postUserNickname: post.nickname, userProfileImage: user.profileImage, postUserProfileImage: post.profileImage, userEnabled: true, postUserEnabled: true, userNotification: user.chatNotification, postUserNotification: post.userNotification, userLocation: user.location, postUserLocation: post.userLocation, messages: [], postId: post.id, postImage: postThumbnail, postTitle: post.postTitle, postStatus: post.postStatus)
        
        return newChat
    }
    
}
