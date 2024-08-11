//
//  ChatListViewModel.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

//import Foundation
//
//@MainActor
//class ChatListViewModel {
//    private var firestoreManager = FirestoreManager()
//    
//    var chatRooms: [ChatRoom] = [] {
//        didSet {
//            updateUI?()
//        }
//    }
//    
//    var updateUI: (() -> Void)?
//    
//    func fetchChatRooms() {
//        firestoreManager.fetchChatRooms { [weak self] chatRooms in
//            self?.chatRooms = chatRooms
//        }
//    }
//    
//    func deleteChatRoom(at index: Int) async {
//        guard index >= 0 && index < chatRooms.count else {
//            print("index out of range")
//            return
//        }
//        
//        let chatRoom = chatRooms[index]
//        
//        do {
//            let idString = chatRoom.id
//            try await firestoreManager.deleteChatRoom(id: idString)
//            chatRooms.remove(at: index)
//        } catch {
//            print("Error deleting chat room: \(error.localizedDescription)")
//        }
//    }
//}
