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
    
    var user: User?
    
    // MARK: - User
    // 사용자 데이터 가져오기
    /// listener를 통한 실시간 데이터 변경사항 반영
    func fetchUser(id: String, onUpdate: @escaping (User?) -> Void) {
        let docRef = db.collection("users").document(id)
        
        docRef.getDocument { [weak self] (document, error) in
            guard self != nil else {
                print("self is no longer available")
                return
            }
            
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: User.self)
                    self?.user = userData
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
                self?.user = updatedUser
                print("User updated: \(String(describing: self?.user))")
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
        let ownerQuery = db.collection("chatRooms").whereField("ownerId", isEqualTo: userId)
        let sitterQuery = db.collection("chatRooms").whereField("sitterId", isEqualTo: userId)
        
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
    func deleteChatRoom(id: String) async throws {
        let docRef = db.collection("chatRooms").document(id)
        try await docRef.delete()
    }
}
