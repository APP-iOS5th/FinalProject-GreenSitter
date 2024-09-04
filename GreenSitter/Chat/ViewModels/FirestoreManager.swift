//
//  FirestoreManager.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirestoreManager {
    private let db = Firestore.firestore()
    
    // MARK: - User
    func fetchUser(onUpdate: @escaping (User?) -> Void) {
        // 현재 로그인된 사용자의 userId 가져오기
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }

        // Firestore에서 특정 문서 가져오기
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
        let userId = chatRoom.userId
        let postUserId = chatRoom.postUserId
        let postId = chatRoom.postId
        let documentRef = db.collection("chatRooms").document(chatRoom.id)
        
        do {
            try await documentRef.setData(from: chatRoom)
            print("Message saved successfully")
        } catch let error {
            print("Failed to save chatRoom: \(error.localizedDescription)")
        }
    }
    
    // 채팅방 중복 체크
    func chatRoomExists(userId: String, postUserId: String, postId: String) async -> ChatRoom? {
        let query = db.collection("chatRooms")
            .whereField("userId", isEqualTo: userId)
            .whereField("postUserId", isEqualTo: postUserId)
            .whereField("postId", isEqualTo: postId)
            .whereField("userEnabled", isEqualTo: true)
        
        do {
            let snapshot = try await query.getDocuments()
            let chatRoom = snapshot.documents.compactMap { document in
                try? document.data(as: ChatRoom.self)
            }.first
            return chatRoom
        } catch {
            print("Error checking if chat room exists: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 채팅방 데이터 가져오기
    func fetchChatRooms(userId: String) async throws -> [ChatRoom] {
        // 사용자 아이디와 userId가 같은 문서와 사용자 아이디와 postUserId가 같은 문서 필터링
        let userQuery = db.collection("chatRooms")
            .whereField("userId", isEqualTo: userId)
            .whereField("userEnabled", isEqualTo: true)

        let postUserQuery = db.collection("chatRooms")
            .whereField("postUserId", isEqualTo: userId)
            .whereField("postUserEnabled", isEqualTo: true)

        do {
            // 사용자 관련 채팅방 가져오기
            let userSnapshot = try await userQuery.getDocuments()
            let userChatRooms = userSnapshot.documents.compactMap { document in
                return try? document.data(as: ChatRoom.self)
            }
            
            // 게시물 사용자 관련 채팅방 가져오기
            let postUserSnapshot = try await postUserQuery.getDocuments()
            let postUserChatRooms = postUserSnapshot.documents.compactMap { document in
                return try? document.data(as: ChatRoom.self)
            }
            
            // 두 채팅방 리스트를 합치기
            let allChatRooms = Array(userChatRooms + postUserChatRooms)
            
            return allChatRooms
        } catch {
            print("Error fetching chat rooms: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 채팅방 데이터 삭제
    func deleteChatRoom(userId: String, chatRoom: ChatRoom) async throws -> ChatRoom {
        let docRef = db.collection("chatRooms").document(chatRoom.id)
        var updatedChatRoom = chatRoom
        
        if userId == updatedChatRoom.userId {
            updatedChatRoom.userEnabled = false
        } else if userId == chatRoom.postUserId {
            updatedChatRoom.postUserEnabled = false
        }
        
        if updatedChatRoom.userEnabled == false && updatedChatRoom.postUserEnabled == false {
            updatedChatRoom.enabled = false
        }
        
        try await docRef.updateData([
            "userEnabled": updatedChatRoom.userEnabled,
            "postUserEnabled": updatedChatRoom.postUserEnabled,
            "enabled": updatedChatRoom.enabled
        ])
        
        return updatedChatRoom
    }
    
    // 채팅방 알림 설정 업데이트
    func updateNotificationSetting(chatRoomId: String, userNotification: Bool, postUserNotification: Bool) async throws {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)

        try await chatRoomRef.updateData([
            "userNotification": userNotification,
            "postUserNotification": postUserNotification
        ])
        
        print("Notification settings updated successfully for chat room \(chatRoomId).")
    }
    
    // 채팅방 읽음 처리 업데이트
    func markMessagesAsRead(chatRoomId: String, userId: String, unreadMessages: [Message]) async throws -> [Message] {
        let messagesCollectionRef = db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")

        var updatedMessages: [Message] = []

        // 배치 작업
        let batch = db.batch()
        
        // 읽지 않은 메시지들에 대해 isRead를 true로 업데이트
        for var message in unreadMessages {
            if message.receiverUserId == userId && !message.isRead {
                message.isRead = true
                let documentRef = messagesCollectionRef.document(message.id)
                batch.updateData(["isRead": true], forDocument: documentRef)
                updatedMessages.append(message)
            }
        }
        
        try await batch.commit()
        
        print("isRead settings updated successfully for chat room \(chatRoomId).")
        
        // 업데이트된 메시지 배열을 반환
        return updatedMessages
    }
    
    // MARK: - Message
    // 채팅 메세지 저장
    func saveMessage(chatRoomId: String, message: Message) async throws {
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
    
    // 채팅목록 마지막 메세지 데이터 가져오기
    /// listener를 통한 실시간 데이터 변경사항 반영
    func fetchLastMessages(chatRoomId: String) -> AsyncStream<[Message]> {
        AsyncStream { continuation in
            let messagesQuery = db.collection("chatRooms")
                .document(chatRoomId)
                .collection("messages")
                .order(by: "createDate", descending: true)
                .limit(to: 1)
            
            let listener = messagesQuery.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.yield(with: .failure(error as! Never))
                    return
                }
                
                guard let snapshot = snapshot else {
                    continuation.yield(with: .success([]))
                    return
                }
                
                if snapshot.metadata.hasPendingWrites {
                    print("Local writes have not yet been committed to the server.")
                    return
                }
                
                let messages: [Message] = snapshot.documents.compactMap { document in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print("Error decoding message: \(error.localizedDescription)")
                        return nil
                    }
                }
                
                continuation.yield(with: .success(messages))
            }
            
            // AsyncStream이 종료될 때 listener 해제
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    // 안읽은 메세지 데이터 가져오기
    /// listener를 통한 실시간 데이터 변경사항 반영
    func fetchUnreadMessages(chatRoomId: String, userId: String) -> AsyncStream<[Message]> {
        AsyncStream { continuation in
            let messagesQuery = db.collection("chatRooms")
                .document(chatRoomId)
                .collection("messages")
                .whereField("isRead", isEqualTo: false) // 읽지 않은 메시지 필터링
                .whereField("receiverUserId", isEqualTo: userId) // 수신자가 현재 사용자
            
            let listener = messagesQuery.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.yield(with: .failure(error as! Never))
                    return
                }
                
                guard let snapshot = snapshot else {
                    continuation.yield(with: .success([]))
                    return
                }
                
                if snapshot.metadata.hasPendingWrites {
                    print("Local writes have not yet been committed to the server.")
                    return
                }
                
                let messages: [Message] = snapshot.documents.compactMap { document in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print("Error decoding message: \(error.localizedDescription)")
                        return nil
                    }
                }
                
                continuation.yield(with: .success(messages))
            }
            
            // AsyncStream이 종료될 때 listener 해제
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    // 메세지 데이터 가져오기
    /// listener를 통한 실시간 데이터 변경사항 반영
    func fetchMessages(chatRoomId: String) -> AsyncStream<[Message]> {
        AsyncStream { continuation in
        let messagesQuery = db.collection("chatRooms")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "createDate", descending: false) // 메시지 보낸 시간순 정렬

        let listener = messagesQuery.addSnapshotListener { snapshot, error in
            if let error = error {
                continuation.yield(with: .failure(error as! Never))
                return
            }
            
            guard let snapshot = snapshot else {
                continuation.yield(with: .success([]))
                return
            }
            
            if snapshot.metadata.hasPendingWrites {
                print("Local writes have not yet been committed to the server.")
                return
            }
            
            let messages: [Message] = snapshot.documents.compactMap { document in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error decoding message: \(error.localizedDescription)")
                    return nil
                }
            }
            
            continuation.yield(with: .success(messages))
        }
        
        // AsyncStream이 종료될 때 listener 해제
        continuation.onTermination = { _ in
            listener.remove()
        }
    }
}
    // 스토리지에 저장된 path를 downloadURL로 변환
    func imagePathToDownloadURLString(imagePath: String) async -> String {
        let storageRef = Storage.storage().reference()
        var downloadURLString = ""
        do {
            let downloadURL = try await storageRef.child(imagePath).downloadURL()
            downloadURLString = downloadURL.absoluteString
        } catch {
            print(error.localizedDescription)
        }
        return downloadURLString
    }
    
    func updatePlanNotification(chatRoomId: String, messageId: String, ownerNotification: Bool, sitterNotification: Bool) async throws {
        let planRef = db.collection("chatRooms").document(chatRoomId)
            .collection("messages").document(messageId)

        try await planRef.updateData([
            "plan.ownerNotification": ownerNotification,
            "plan.sitterNotification": sitterNotification
        ])
    }
    
    func updatePostStatusAfterMakePlan(chatRoomId: String, planType: PlanType, postId: String) async throws {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        let postRef = db.collection("posts").document(postId)
        
        switch planType {
        case .leavePlan:
            try await chatRoomRef.updateData([
                "hasLeavePlan" : true,
                "postStatus" : PostStatus.inTrade.rawValue
            ])
            try await postRef.updateData([
                "postStatus" : PostStatus.inTrade.rawValue
            ])
        case .getBackPlan:
            try await chatRoomRef.updateData([
                "hasGetBackPlan" : true,
                "postStatus" : PostStatus.inTrade.rawValue
            ])
            try await postRef.updateData([
                "postStatus" : PostStatus.inTrade.rawValue
            ])
        }
    }
    
    func updatePostStatusAfterCancelPlan(chatRoomId: String, planType: PlanType, postId: String) async throws -> Bool {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        let postRef = db.collection("posts").document(postId)
        
        switch planType {
        case .leavePlan:
            try await chatRoomRef.updateData([
                "hasLeavePlan" : false,
            ])
            let chatRoomSnapshot = try await chatRoomRef.getDocument()
            if let chatRoomData = chatRoomSnapshot.data(),
               let hasGetBackPlan = chatRoomData["hasGetBackPlan"] as? Bool,
               hasGetBackPlan == false {
                try await chatRoomRef.updateData([
                    "postStatus" : PostStatus.beforeTrade.rawValue
                ])
                try await postRef.updateData([
                    "postStatus" : PostStatus.beforeTrade.rawValue
                ])
                return true
            }
        case .getBackPlan:
            try await chatRoomRef.updateData([
                "hasGetBackPlan" : false,
            ])
            let chatRoomSnapshot = try await chatRoomRef.getDocument()
            if let chatRoomData = chatRoomSnapshot.data(),
               let hasLeavePlan = chatRoomData["hasLeavePlan"] as? Bool,
               hasLeavePlan == false {
                try await chatRoomRef.updateData([
                    "postStatus" : PostStatus.beforeTrade.rawValue
                ])
                try await postRef.updateData([
                    "postStatus" : PostStatus.beforeTrade.rawValue
                ])
                return true
            }
        }
        return false
    }
    
    func completeTrade(chatRoomId: String, postId: String, recipientId: String) async throws {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        let postRef = db.collection("posts").document(postId)
        
        try await chatRoomRef.updateData([
            "postStatus" : PostStatus.completedTrade.rawValue
        ])
        
        try await postRef.updateData([
            "postStatus" : PostStatus.completedTrade.rawValue,
            "recipientId" : recipientId
        ])
    }
    
    func fetchChatHasLeavePlan(chatRoomId: String) async throws -> Bool {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
         let hasLeavePlan = try await chatRoomRef.getDocument().get("hasLeavePlan") as? Bool ?? true
        return hasLeavePlan
    }
    
    func fetchChatHasGetBackPlan(chatRoomId: String) async throws -> Bool {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
         let hasGetBackPlan = try await chatRoomRef.getDocument().get("hasGetBackPlan") as? Bool ?? true
        return hasGetBackPlan
    }
    
    func fetchChatPostStatus(chatRoomId: String) async throws -> PostStatus {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        let postStatus: PostStatus
        let postStatusString = try await chatRoomRef.getDocument().get("postStatus") as? String
        switch postStatusString {
        case PostStatus.beforeTrade.rawValue:
            postStatus = .beforeTrade
        case PostStatus.inTrade.rawValue:
            postStatus = .inTrade
        case PostStatus.completedTrade.rawValue:
            postStatus = .completedTrade
        default:
            postStatus = .completedTrade
        }
        return postStatus

    }
}
