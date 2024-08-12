//
//  DataManager.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/12/24.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private var firestoreManager = FirestoreManager()
    private var user: User?
    
    private init() {}
    
    func loadUser(id: String) {
        firestoreManager.fetchUser(id: id) { [weak self] fetchedUser in
            guard let self = self else {
                print("UserManager instance is no longer available")
                return
            }
            self.user = fetchedUser
        }
    }
}
