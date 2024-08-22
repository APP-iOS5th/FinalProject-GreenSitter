//
//  LoginViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/14/24.
//

import Foundation   

class LoginViewModel: ObservableObject {
    @Published var user: User?
    
    func userFetchFirbase(profileImage: String, nickname: String, location: Location) {
        self.user = User(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), profileImage: profileImage, nickname: nickname, location: location, platform: "", levelPoint: Level.seeds, exp: 0, aboutMe: "", chatNotification: false)
    }
}
