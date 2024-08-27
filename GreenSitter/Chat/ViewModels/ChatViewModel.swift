//
//  ChatViewModel.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

import UIKit
import FirebaseAuth

@MainActor
class ChatViewModel {
    private var firestoreManager = FirestoreManager()
    private let firestorageManager = FirestorageManager()
    
    // 로그인 여부를 나타내는 변수
    var isLoggedIn = true /// 임시로 true, false로 바꾸기
    var hasChats = false
    
    // 임시 유저 id
    let userId = "250e8400-e29b-41d4-a716-446655440003"
//    var userId: String? {
//        didSet {
//            isLoggedIn = userId != nil
//        }
//    }
    
    var chatRooms: [ChatRoom] = [] {
        didSet {
            hasChats = !(chatRooms.isEmpty)
            updateUI?()
        }
    }
    
    var lastMessages: [String:[Message]] = [:] {
        didSet {
            updateUI?()
        }
    }
    
    var unreadMessages: [String:[Message]] = [:] {
        didSet {
            updateUI?()
        }
    }
    
    var messages: [String:[Message]] = [:] {
        didSet {
            updateUI?()
        }
    }

    var updateUI: (() -> Void)?
    
    init() {
        // 현재 사용자 ID 설정
//        self.userId = LoginViewModel.shared.user?.id
//        self.isLoggedIn = userId != nil
    }
    
//    func loadUser(completion: @escaping () -> Void) {
//        firestoreManager.fetchUser() { [weak self] updatedUser in
//            self?.user = updatedUser
//            completion()
//        }
//    }
    
    func loadChatRooms() async throws -> [ChatRoom] {
        do {
            let updatedChatRooms = try await firestoreManager.fetchChatRooms(userId: userId)
            self.chatRooms = updatedChatRooms
            return updatedChatRooms
        } catch {
            print("Error loading chat rooms: \(error.localizedDescription)")
            throw error
        }
    }
    
    func loadLastMessages(chatRoomId: String) async -> AsyncStream<[Message]> {
        return firestoreManager.fetchLastMessages(chatRoomId: chatRoomId)
    }
    
    func loadUnreadMessages(chatRoomId: String) async -> AsyncStream<[Message]> {
        return firestoreManager.fetchUnreadMessages(chatRoomId: chatRoomId, userId: userId)
    }
    
    func loadMessages(chatRoomId: String) async -> AsyncStream<[Message]>  {
        return firestoreManager.fetchMessages(chatRoomId: chatRoomId)
    }
    
    func deleteChatRoom(at index: Int) async throws {
        guard index >= 0 && index < self.chatRooms.count else {
            print("index out of range")
            return
        }
        
        let chatRoom = self.chatRooms[index]
        
        do {
            let idString = chatRoom.id
            let updatedChatRoom = try await firestoreManager.deleteChatRoom(docId: idString, userId: userId, chatRoom: chatRoom)
            self.chatRooms[index] = updatedChatRoom
        } catch {
            print("Error deleting chat room: \(error.localizedDescription)")
        }
    }
    
    func downloadImage(from url: URL, to imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "")")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageView.image = image
                } else {
                    print("Failed to convert data to image")
                }
            }
        }.resume()
    }
    
    // 채팅방 알림 설정 업데이트
    func updateNotification(chatRoomId: String, userNotification: Bool, postUserNotification: Bool) async throws {
        do {
            try await firestoreManager.updateNotificationSetting(chatRoomId: chatRoomId, userNotification: userNotification, postUserNotification: postUserNotification)
        } catch {
            print("Error updating notification of chatRoom: \(error.localizedDescription)")
        }
    }
    
    // 채팅방 읽음 처리 업데이트
    func updateUnread(chatRoomId: String) async throws {
        do {
            let readMessages = try await firestoreManager.markMessagesAsRead(chatRoomId: chatRoomId, userId: self.userId, unreadMessages: self.unreadMessages[chatRoomId]!)
            self.unreadMessages[chatRoomId] = []
        } catch {
            print("Error updating notification of chatRoom: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - MessageInputViewController Button Methods
    // send button
    func sendButtonTapped(text: String?, chatRoom: ChatRoom) {
        guard let messageText = text, !messageText.isEmpty else {
            print("Message is empty")
            return
        }
        
        // TODO: - userId 수정
        let receiverUserId: String?
        if userId == chatRoom.userId {
            receiverUserId = chatRoom.postUserId
        } else {
            receiverUserId = chatRoom.userId
        }
        
        let textMessage = Message(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), senderUserId: userId, receiverUserId: receiverUserId!, isRead: false, messageType: .text, text: messageText, image: nil, plan: nil)
        
        // 로컬 메시지 리스트에 메시지 추가
        if var chatRoomMessages = self.messages[chatRoom.id] {
            chatRoomMessages.append(textMessage)
            self.messages[chatRoom.id] = chatRoomMessages
        } else {
            self.messages[chatRoom.id] = [textMessage]
        }
        
        Task {
            do {
                try await firestoreManager.saveMessage(chatRoomId: chatRoom.id, message: textMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
                // Firestore에 저장 실패 시, 로컬 메시지 리스트에서 해당 메시지 제거
                if var chatRoomMessages = self.messages[chatRoom.id] {
                    chatRoomMessages.removeAll { $0.id == textMessage.id }
                    self.messages[chatRoom.id] = chatRoomMessages
                }
                return
            }
        }
    }
    
    //MARK: - 이미지 메세지 전송
    func sendImageMessage(images: [UIImage], chatRoom: ChatRoom) {
        guard !images.isEmpty else {
            print("No Image")
            return
        }
        
        // TODO: - userId 수정
        let receiverUserId: String?
        if userId == chatRoom.userId {
            receiverUserId = chatRoom.postUserId
        } else {
            receiverUserId = chatRoom.userId
        }
        
        var imagePaths = [String]()
        
        Task {
            //이미지 파이어베이스 스토리지에 저장
            await withTaskGroup(of: String?.self) { group in
                for image in images {
                    group.addTask {
                        guard let imageData = self.firestorageManager.imageToData(image: image) else {
                            print("Failed to transform image to data")
                            return nil
                        }
                        
                        do {
                            let imagePath = try await self.firestorageManager.saveImage(data: imageData)
                            return imagePath
                        } catch {
                            print("Failed to save image: \(error.localizedDescription)")
                            return nil
                        }
                    }
                }
                
                for await imagePath in group {
                    if let path = imagePath {
                        imagePaths.append(path)
                    }
                }
            }
            // 파이어 스토어 메세지 저장
            let imageMessage = Message(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), senderUserId: userId, receiverUserId: receiverUserId!, isRead: false, messageType: .image, text: nil, image: imagePaths, plan: nil)
            
            // 로컬 메시지 리스트에 메시지 추가
            if var chatRoomMessages = self.messages[chatRoom.id] {
                chatRoomMessages.append(imageMessage)
                self.messages[chatRoom.id] = chatRoomMessages
            } else {
                self.messages[chatRoom.id] = [imageMessage]
            }

            // UI 업데이트
//            self.updateUI?()
            
            do {
                try await firestoreManager.saveMessage(chatRoomId: chatRoom.id, message: imageMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
                // Firestore에 저장 실패 시, 로컬 메시지 리스트에서 해당 메시지 제거
                if var chatRoomMessages = self.messages[chatRoom.id] {
                    chatRoomMessages.removeAll { $0.id == imageMessage.id }
                    self.messages[chatRoom.id] = chatRoomMessages
                }
//                self.updateUI?()
                return
            }
        }
    }
    
    //MARK: - 파이어베이스 스토리지에서 이미지 가져오기
    func loadChatImages(imagePaths: [String]) async -> [UIImage] {
        var images = [UIImage]()
        
        //파이어베이스 스토리지에서 이미지 가져오기
        await withTaskGroup(of: UIImage?.self) { group in
            for imagePath in imagePaths {
                group.addTask {
                    do {
                        let image = try await self.firestorageManager.loadImage(imagePath: imagePath)
                        return image
                    } catch {
                        print("Failed to load image: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
            
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
        }
        
        return images
    }
    
    //MARK: - 약속 메세지 전송
    func sendPlanMessage(plan: Plan, chatRoom: ChatRoom) {
        // TODO: - userId 수정
        let receiverUserId: String?
        if userId == chatRoom.userId {
            receiverUserId = chatRoom.postUserId
        } else {
            receiverUserId = chatRoom.userId
        }
        
        let planMessage = Message(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), senderUserId: userId, receiverUserId: receiverUserId!, isRead: false, messageType: .plan, text: nil, image: nil, plan: plan)
        
        // 로컬 메시지 리스트에 메시지 추가
        if var chatRoomMessages = self.messages[chatRoom.id] {
            chatRoomMessages.append(planMessage)
            self.messages[chatRoom.id] = chatRoomMessages
        } else {
            self.messages[chatRoom.id] = [planMessage]
        }

        // UI 업데이트
//        self.updateUI?()
        
        Task {
            do {
                try await firestoreManager.saveMessage(chatRoomId: chatRoom.id, message: planMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
                // Firestore에 저장 실패 시, 로컬 메시지 리스트에서 해당 메시지 제거
                if var chatRoomMessages = self.messages[chatRoom.id] {
                    chatRoomMessages.removeAll { $0.id == planMessage.id }
                    self.messages[chatRoom.id] = chatRoomMessages
                }
//                self.updateUI?()
                return
            }
        }
    }
}
