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
                        location: Location.sampleLocation,
                        platform: "iOS",
                        levelPoint: 1,
                        aboutMe: "", chatNotification: false
                    )
                } else {
                    self.user?.nickname = nickname
                    self.user?.profileImage = profileImage
                }
                
                // 프로필 이미지 URL을 사용하여 이미지 로드
                if !profileImage.isEmpty {
                    self.loadProfileImage(from: profileImage)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() // 데이터를 업데이트한 후 테이블 뷰를 리로드합니다.
                }
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
    

    //MARK: - gs:// URL을 https:// URL로 변환
    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) // 한 번만 호출
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }




    //MARK: - 이미지 스토리지에서 이미지 파일 불러오기
    func loadProfileImage(from gsURL: String) {
        guard let httpsURLString = convertToHttpsURL(gsURL: gsURL),
              let url = URL(string: httpsURLString) else {
            print("Invalid URL string: \(gsURL)")
            return
        }
        
        print("Fetching image from URL: \(url)") // URL을 로그로 출력하여 확인
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("이미지 다운로드 오류: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            print("Data received with size: \(data.count) bytes")
            
            guard let image = UIImage(data: data) else {
                print("error: 이미지로 변환 실패")
                return
            }
            DispatchQueue.main.async {
                self.imageButton.setImage(image, for: .normal)
            }
        }
        task.resume()
    }




    //MARK: - 이미지 파일 스토리지 업로드
    func uploadImage(image: UIImage, completion: @escaping(String?) -> Void) {
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        
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
                    if let urlString = url?.absoluteString {
                        print("Uploaded image URL: \(urlString)") // URL을 로그로 출력
                        completion(url?.absoluteString)
                    }
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

