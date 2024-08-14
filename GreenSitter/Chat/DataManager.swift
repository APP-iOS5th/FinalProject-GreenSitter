//
//  DataManager.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import Foundation

class UserManager {
    static let shared = UserManager()

    var user: User?
    
    private init() {}

}

class ChatRoomManager {
    static let shared = ChatRoomManager()

    var chatRooms: [ChatRoom]?
    
    private init() {}
    
}
