//
//  FirestoreManager.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    private let db = Firestore.firestore()
    
    // MARK: - User
    // 사용자 데이터 가져오기
    /// listener를 통한 실시간 데이터 변경사항 반영
    func fetchUser(userId: String, onUpdate: @escaping (User?) -> Void) {
        let docRef = db.collection("users").document(userId)
        
        docRef.getDocument { [weak self] (document, error) in
            guard self != nil else {
                print("self is no longer available")
                return
            }
            
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: User.self)
                    onUpdate(userData)
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    onUpdate(nil)
                }
            } else {
                print("User does not exist")
                onUpdate(nil)
            }
        }
        
        docRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard self != nil else {
                print("self is no longer available")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            do {
                let updatedUser = try document.data(as: User.self)
                print("User updated: \(String(describing: updatedUser))")
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - ChatRoom
    // 채팅방 데이터 저장
    func saveChatRoom(_ chatRoom: ChatRoom) async throws {
        let ownerId = chatRoom.ownerId
        let sitterId = chatRoom.sitterId
        let postId = chatRoom.postId
        
        // 중복 검사
        if await chatRoomExists(ownerId: ownerId, sitterId: sitterId, postId: postId) {
            print("Chat room with ownerId \(ownerId), sitterId \(sitterId), and postId \(postId) already exists")
            return
        }
        
        let documentRef = db.collection("chatRooms").document(chatRoom.id)
        
        do {
            try await documentRef.setData(from: chatRoom)
            print("Message saved successfully")
        } catch let error {
            print("Failed to save chatRoom: \(error.localizedDescription)")
        }
    }
    
    // 채팅방 중복 체크
    func chatRoomExists(ownerId: String, sitterId: String, postId: String) async -> Bool {
        let query = db.collection("chatRooms")
            .whereField("ownerId", isEqualTo: ownerId)
            .whereField("sitterId", isEqualTo: sitterId)
            .whereField("postId", isEqualTo: postId)
        
        do {
            let snapshot = try await query.getDocuments()
            return !snapshot.isEmpty
        } catch {
            print("Error checking if chat room exists: \(error.localizedDescription)")
            return false
        }
    }
    
    // 채팅 메세지 저장
    func saveMessage(to chatRoomId: String, message: Message) async throws {
        let messagesCollectionRef = db.collection("chatRooms").document(chatRoomId).collection("messages").document(message.id)
        
        do {
            // 메시지 데이터 저장
            try await messagesCollectionRef.setData(from: message)
            print("Message saved successfully")
        } catch {
            print("Failed to save message: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 채팅방 데이터 가져오기
    /// listener를 통한 실시간 데이터 변경사항 반영
    func fetchChatRooms(userId: String, onUpdate: @escaping ([ChatRoom]) -> Void) {
        // 사용자 아이디와 ownerId가 같은 문서와 사용자 아이디와 sitterId가 같은 문서 필터링
        let ownerQuery = db.collection("chatRooms")
            .whereField("ownerId", isEqualTo: userId)
            .whereField("ownerEnabled", isEqualTo: true)
        let sitterQuery = db.collection("chatRooms")
            .whereField("sitterId", isEqualTo: userId)
            .whereField("sitterEnabled", isEqualTo: true)
        
        ownerQuery.getDocuments { [weak self] ownerSnapshot, error in
            guard self != nil else {
                print("self is no longer available")
                return
            }
            
            if let error = error {
                print("Error fetching chat rooms as owner: \(error.localizedDescription)")
                return
            }
            
            sitterQuery.getDocuments { sitterSnapshot, error in
                if let error = error {
                    print("Error fetching chat rooms as sitter: \(error.localizedDescription)")
                    return
                }
                
                let ownerChatRooms = ownerSnapshot?.documents.compactMap { document in
                    return try? document.data(as: ChatRoom.self)
                } ?? []
                
                let sitterChatRooms = sitterSnapshot?.documents.compactMap { document in
                    return try? document.data(as: ChatRoom.self)
                } ?? []
                
                let allChatRooms = Array(ownerChatRooms + sitterChatRooms)
                
                onUpdate(allChatRooms)

            }
        }
    }
    
    // 채팅방 데이터 삭제
    func deleteChatRoom(docId: String, userId: String, chatRoom: inout ChatRoom) async throws {
        let docRef = db.collection("chatRooms").document(docId)
        
        if userId == chatRoom.ownerId {
            chatRoom.ownerEnabled = false
        } else if userId == chatRoom.sitterId {
            chatRoom.sitterEnabled = false
        }
        
        if chatRoom.ownerEnabled == false && chatRoom.sitterEnabled == false {
            chatRoom.enabled = false
        }
        
        try await docRef.updateData([
            "ownerEnabled": chatRoom.ownerEnabled,
            "sitterEnabled": chatRoom.sitterEnabled,
            "enabled": chatRoom.enabled
        ])
    }
}
