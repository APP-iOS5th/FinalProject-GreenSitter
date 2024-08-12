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
    let userId = "250e8400-e29b-41d4-a716-446655440001"

    var chatRooms: [ChatRoom] = [] {
        didSet {
            updateUI?()
        }
    }
    
    var updateUI: (() -> Void)?
    
    func fetchChatRooms() {
        firestoreManager.fetchChatRooms(userId: userId) { [weak self] chatRooms in
            self?.chatRooms = chatRooms
        }
    }
    
    func deleteChatRoom(at index: Int) async {
        guard index >= 0 && index < chatRooms.count else {
            print("index out of range")
            return
        }
        
        let chatRoom = chatRooms[index]
        
        do {
            let idString = chatRoom.id
            try await firestoreManager.deleteChatRoom(id: idString)
            chatRooms.remove(at: index)
        } catch {
            print("Error deleting chat room: \(error.localizedDescription)")
        }
    }
}
