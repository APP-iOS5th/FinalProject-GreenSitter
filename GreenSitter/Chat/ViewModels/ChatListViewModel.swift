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

    // 샘플 유저 id
    let userId = "250e8400-e29b-41d4-a716-446655440003"
    var user = UserManager.shared.user {
        didSet {
            updateUI?()
        }
    }
    
    var chatRooms = ChatRoomManager.shared.chatRooms {
        didSet {
            updateUI?()
        }
    }
    
    var updateUI: (() -> Void)?
    
    func loadUser() {
        firestoreManager.fetchUser(userId: userId) { [weak self] updatedUser in
            self?.user = updatedUser
        }
    }
    
    func loadChatRooms() {
        firestoreManager.fetchChatRooms(userId: userId) { [weak self] updatedchatRooms in
            self?.chatRooms = updatedchatRooms
        }
    }
    
    func deleteChatRoom(at index: Int) async {
        guard var chatRooms = chatRooms else {
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
