//
//  FirestoreManager.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/11/24.
//

//import Foundation
//import FirebaseFirestore
//
//class FirestoreManager {
//    private let db = Firestore.firestore()
//    
//    // 채팅방 데이터 가져오기
//    /// listener를 통한 실시간 데이터 변경사항 반영
//    func fetchChatRooms(onUpdate: @escaping ([ChatRoom]) -> Void) {
//        db.collection("chatRooms").addSnapshotListener { [weak self] snapshot, error in
//            guard self != nil else {
//                print("self is no longer available")
//                return
//            }
//            
//            if let error = error {
//                print("Error fetching chat rooms: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let snapshot = snapshot else {
//                print("Snapshot is nil")
//                return
//            }
//            
//            let chatRooms = snapshot.documents.compactMap { document in
//                try? document.data(as: ChatRoom.self)
//            }
//            
//            onUpdate(chatRooms)
//        }
//    }
//    
//    // 채팅방 데이터 삭제
//    func deleteChatRoom(id: String) async throws {
//        let documentId = id
//        try await db.collection("chatRooms").document(documentId).delete()
//    }
//}
