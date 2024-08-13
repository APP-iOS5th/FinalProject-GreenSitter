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
        let documentRef = db.collection("chatRooms").document(chatRoom.id)
        
        do {
            try await documentRef.setData(from: chatRoom)
        } catch let error {
            print("Save chat room data error: \(error.localizedDescription)")
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
