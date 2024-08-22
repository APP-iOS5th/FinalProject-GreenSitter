//
//  LoginViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/14/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var user: User?
    let db = Firestore.firestore()
    
    func userFetchFirebase(profileImage: String, nickname: String, location: Location) {
        self.user = User(id: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), profileImage: profileImage, nickname: nickname, location: location, platform: "", levelPoint: Level.seeds, exp: 0, aboutMe: "", chatNotification: false)
    }
    
    func updateUserLocation(with location: Location) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }
        
        let userLocationData: [String: Any] = [
            "location": location.toDictionary(),
        ]
        db.collection("users").document(userId).setData(userLocationData, merge: true) { error in
            if let error = error {
                print("Failed to update user location: \(error.localizedDescription)")
            } else {
                print("User location updated successfully with address: \(location)")
            }
        }

        print("Attempting to update user location with address: \(location)")
    }
}
