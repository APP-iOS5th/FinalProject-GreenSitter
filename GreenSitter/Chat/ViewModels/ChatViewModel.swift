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
    let userId = "250e8400-e29b-41d4-a716-446655440001"
    var user: User? {
        didSet {
//            isLoggedIn = user != nil
            updateUI?()
        }
    }
    
    var chatRooms: [ChatRoom]? {
        didSet {
            hasChats = !(chatRooms?.isEmpty ?? true)
            updateUI?()
        }
    }
    
    var chatRoom: ChatRoom?

    var updateUI: (() -> Void)?
    
    func loadUser(completion: @escaping () -> Void) {
        firestoreManager.fetchUser(userId: userId) { [weak self] updatedUser in
            self?.user = updatedUser
            completion()
        }
    }
    
    func loadChatRooms(completion: @escaping () -> Void) {
        firestoreManager.fetchChatRooms(userId: userId) { [weak self] updatedchatRooms in
            self?.chatRooms = updatedchatRooms
            completion()
        }
    }
    
    func deleteChatRoom(at index: Int) async throws {
        guard let chatRooms = self.chatRooms else {
            return
        }
        
        guard index >= 0 && index < chatRooms.count else {
            print("index out of range")
            return
        }
        
        var chatRoom = chatRooms[index]
        
        do {
            let idString = chatRoom.id
            try await firestoreManager.deleteChatRoom(docId: idString, userId: userId, chatRoom: &chatRoom)
            self.chatRooms?.remove(at: index)
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
    func sendButtonTapped(text: String?) {
        guard let messageText = text, !messageText.isEmpty else {
            print("Message is empty")
            return
        }

        guard let postUserId = chatRoom?.postUserId else {
            print("Error: postUserId is nil")
            return
        }
        
        guard let chatRoomId = chatRoom?.id else {
            print("Error: chatRoomId is nil")
            return
        }

        let textMessage = Message(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), senderUserId: userId, receiverUserId: postUserId, isRead: false, messageType: .text, text: messageText, image: nil, plan: nil)
        
        Task {
            do {
                try await firestoreManager.saveMessage(to: chatRoomId, message: textMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
                return
            }
        }
    }
}
