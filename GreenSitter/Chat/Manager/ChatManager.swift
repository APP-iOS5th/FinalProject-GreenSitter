//
//  ChatManager.swift
//  GreenSitter
//
//  Created by 박지혜 on 9/5/24.
//

import Foundation

class ChatManager {
    static let shared = ChatManager()
    var currentChatRoomId: String?
    
    private init() {}
}
