//
//  ProfileViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

extension ProfileViewController {
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
            if let document = document, document.exists {
                let data = document.data()
                let nickname = data?["nickname"] as? String ?? "닉네임 없음"
//                let location = data?["location"] as? String ?? "위치정보없음"
                let profileImage = data?["profileImage"] as? String ?? ""

                
                // user 객체가 nil일 경우 User 객체를 초기화
                if self.user == nil {
                    self.user = User(
                        id: userId,
                        enabled: true,
                        createDate: Date(),
                        updateDate: Date(),
                        profileImage: profileImage,
                        nickname: nickname,
                        location: Location(locationId: UUID().uuidString, enabled: true, createDate: Date(), updateDate: Date(), exactLongitude: 1.0, exactLatitude: 1.0, optionLongitude: 1.0, optionLatitude: 1.0),
                        platform: "iOS",
                        levelPoint: 1, // 예시 값입니다. 실제 값으로 교체하세요.
                        aboutMe: "", chatNotification: false
                    )
                } else {
                    self.user?.nickname = nickname
                }
                
                self.tableView.reloadData() // 데이터를 업데이트한 후 테이블 뷰를 리로드합니다.
            } else {
                print("Document does not exist")
            }
        }
    }

    
    //MARK: - 변경된 사진을 파이어베이스에 저장
    func updateNickname(_ profileImage: String) {
        guard let user = Auth.auth().currentUser else {
            print("Error: Firebase authResult is nil.")
            return
        }
        
        let userData: [String: Any] = ["profileImage": profileImage]
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore Writing Error: \(error)")
            } else {
                print("Nickname successfully saved!")
            }
        }
    }
    
    //MARK: - 이미지 파일 스토리지 업로드
    func uploadImage(image: UIImage, completion: @escaping(String?) -> Void) {
        let storageRef = storage.reference().child("gs://greensitter-6dedd.appspot.com/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error: Unable to convert UIImage to Data")
            completion(nil)
            return
        }
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Firebase Storage Error: \(error)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    //MARK: - 로그아웃
    func logout() {
        // Implement logout functionality here
    }
    
    //MARK: - 회원 탈퇴
    func accountDeletion() {
        // Implement account deletion functionality here
    }
}

