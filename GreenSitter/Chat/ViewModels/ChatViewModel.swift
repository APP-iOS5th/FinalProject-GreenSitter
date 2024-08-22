//
//  ChatViewModel.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

import UIKit

@MainActor
class ChatViewModel {
    private var firestoreManager = FirestoreManager()
    
    // 로그인 여부를 나타내는 변수
    var isLoggedIn = true /// 임시로 true, false로 바꾸기
    var hasChats = false
    
    // 임시 유저 id
    let userId = "250e8400-e29b-41d4-a716-446655440002"
    var user: User? {
        didSet {
//            isLoggedIn = user != nil
            updateUI?()
        }
    }
    
    var chatRooms: [ChatRoom] = [] {
        didSet {
            hasChats = !(chatRooms.isEmpty)
            updateUI?()
        }
    }
    
    var messages: [String:[Message]] = [:]

    var updateUI: (() -> Void)?
    
    init() {
        loadUser {}
    }
    
    func loadUser(completion: @escaping () -> Void) {
        firestoreManager.fetchUser() { [weak self] updatedUser in
            self?.user = updatedUser
            completion()
        }
    }
    
    func loadChatRooms(completion: @escaping () -> Void) {
        firestoreManager.fetchChatRooms(userId: userId) { [weak self] updatedchatRooms in
            guard let self = self else { return }
            self.chatRooms = updatedchatRooms
            let dispatchGroup = DispatchGroup()
            
            for updatedChatRoom in updatedchatRooms {
                dispatchGroup.enter()
                self.loadMessages(chatRoomId: updatedChatRoom.id) {
                    // TODO: - 새로운 메세지가 self.messages에 잘 저장되는데 불러올 때 에러남
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion()
                
            }
            
        }
    }
    
    func loadMessages(chatRoomId: String, completion: @escaping () -> Void) {
        firestoreManager.fetchMessages(chatRoomId: chatRoomId) { [weak self] updatedMessages in
            guard let self = self else {
                completion()
                return
            }
            self.messages[chatRoomId] = updatedMessages
            
            completion()
        }
    }
    
    func deleteChatRoom(at index: Int) async throws {
        guard index >= 0 && index < chatRooms.count else {
            print("index out of range")
            return
        }
        
        var chatRoom = chatRooms[index]
        
        do {
            let idString = chatRoom.id
            try await firestoreManager.deleteChatRoom(docId: idString, userId: userId, chatRoom: &chatRoom)
            self.chatRooms.remove(at: index)
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

        // UI 업데이트
//        self.updateUI?()
        
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
//                self.updateUI?()
                return
            }
        }
    }
}
