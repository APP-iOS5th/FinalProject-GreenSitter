//
//  PostDetailViewModel.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

// PostCareProviderTableVC 불러오는 함수
// PostCareSeekterTableVC 불러오는 함수
// Seeker,Provider 데이터 지우는 함수

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PostDetailViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var firestoreManager = FirestoreManager()

    @Published var selectedPost: Post?
    
    // MARK: - Post 삭제
    func deletePost(postId: String, completion: @escaping (Bool) -> Void) {
        db.collection("posts").document(postId).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Document successfully removed!")
                completion(true)
            }
        }
    }
    
    var user = Auth.auth().currentUser
    
    var onChatButtonTapped: ((ChatRoom) -> Void)?
    
    // 채팅버튼 클릭 시 호출될 메서드
    func chatButtonTapped() async {
        guard let newChat = makeChat() else {
            print("Failed to create new chat")
            return
        }
        
        do {
            // 중복 체크
            if let existingChatRoom = await self.firestoreManager.chatRoomExists(userId: newChat.userId, postUserId: newChat.postUserId, postId: newChat.postId) {
                print("Chat room already exists, navigating to existing chat room.")
                
                if let onChatButtonTapped = self.onChatButtonTapped {
                    DispatchQueue.main.async {
                        onChatButtonTapped(existingChatRoom)
                    }
                } else {
                    print("onChatButtonTapped is not set")
                }
                
                return
            }
            
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
    private func makeChat() -> ChatRoom? {
        
        // 게시물 썸네일
        guard let postThumbnail = selectedPost?.postImages?.first else {
            return nil
        }
        
        // TODO: - messages는 하위 컬렉션으로 저장
//        let newChat = ChatRoom(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), userId: user!.uid, postUserId: selectedPost!.userId, userNickname: user.nickname, postUserNickname: selectedPost!.nickname, userProfileImage: user.profileImage, postUserProfileImage: selectedPost!.profileImage, userEnabled: true, postUserEnabled: true, userNotification: user.chatNotification, postUserNotification: selectedPost!.userNotification, userLocation: user.location, postUserLocation: selectedPost!.userLocation, messages: [], postId: selectedPost!.id, postImage: postThumbnail, postTitle: selectedPost!.postTitle, postStatus: selectedPost!.postStatus)
        
//        return newChat
        return nil
    }
    
}
