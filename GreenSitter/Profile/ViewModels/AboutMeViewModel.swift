//
//  AboutMeViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

extension AboutMeViewController {

    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                print("Document data: \(data)") // Firestore에서 가져온 데이터 출력
            } else {
                print("Document does not exist")
            }
        }
    }

}
