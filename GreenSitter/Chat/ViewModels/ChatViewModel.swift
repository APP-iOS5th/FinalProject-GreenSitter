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
    private let firestorageManager = FirestorageManager()
    
    // 로그인 여부를 나타내는 변수
    var isLoggedIn = true /// 임시로 true, false로 바꾸기
    var hasChats = false
    
    // 임시 유저 id
    let userId = "250e8400-e29b-41d4-a716-446655440003"
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
    
    var messages: [Message]? {
        didSet {
            updateUI?()
        }
    }

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
    
    func loadMessages(completion: @escaping () -> Void) {
        firestoreManager.fetchMessages(chatRoomId: chatRoom!.id) { [weak self] updatedMessages in
            self?.messages = updatedMessages
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

        guard let userId = chatRoom?.userId else {
            print("Error: userId is nil")
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
        
        // TODO: - userId 수정
        let receiverUserId: String?
        if userId == userId {
            receiverUserId = postUserId
        } else {
            receiverUserId = userId
        }
        
        let textMessage = Message(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), senderUserId: userId, receiverUserId: receiverUserId!, isRead: false, messageType: .text, text: messageText, image: nil, plan: nil)
        
        Task {
            do {
                try await firestoreManager.saveMessage(chatRoomId: chatRoomId, message: textMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
                return
            }
        }
    }
    
    //MARK: - 이미지 메세지 전송
    func sendImageMessage(images: [UIImage]) {
        guard !images.isEmpty else {
            print("No Image")
            return
        }

        guard let userId = chatRoom?.userId else {
            print("Error: userId is nil")
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
        
        // TODO: - userId 수정
        let receiverUserId: String?
        if userId == userId {
            receiverUserId = postUserId
        } else {
            receiverUserId = userId
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
            do {
                try await firestoreManager.saveMessage(chatRoomId: chatRoomId, message: imageMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
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
    func sendPlanMessage(plan: Plan) {
        guard let userId = chatRoom?.userId else {
            print("Error: userId is nil")
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
        
        // TODO: - userId 수정
        let receiverUserId: String?
        if userId == userId {
            receiverUserId = postUserId
        } else {
            receiverUserId = userId
        }
        
        let planMessage = Message(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), senderUserId: userId, receiverUserId: receiverUserId!, isRead: false, messageType: .plan, text: nil, image: nil, plan: plan)
        
        Task {
            do {
                try await firestoreManager.saveMessage(chatRoomId: chatRoomId, message: planMessage)
            } catch {
                print("Failed to save message: \(error.localizedDescription)")
                return
            }
        }
    }
}
