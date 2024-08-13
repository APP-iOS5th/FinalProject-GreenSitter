//
//  ChatListViewModel.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

import Foundation

@MainActor
class ChatListViewModel {
    private var firestoreManager = FirestoreManager()
    
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
        guard var chatRooms = self.chatRooms else {
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
            chatRooms.remove(at: index)
        } catch {
            print("Error deleting chat room: \(error.localizedDescription)")
        }
    }
}
