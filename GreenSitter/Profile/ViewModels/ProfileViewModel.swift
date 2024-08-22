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
import Combine
import AuthenticationServices

extension ProfileViewController {
    
    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase() {
        if user?.id == Auth.auth().currentUser?.uid {
            if let profileImage = user?.profileImage {
                self.loadProfileImage(from: profileImage)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
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
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            // LoginViewController 인스턴스 생성
            let loginViewController = LoginViewController() // 스토리보드 없이 직접 생성
            navigationController?.pushViewController(loginViewController, animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    //MARK: - 회원 탈퇴
    func accountDeletion() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "회원탈퇴시, 모든 가입 정보가 삭제됩니다 \n 다시 로그인하려면 재가입이 필요합니다 \n\n 정말로 회원탈퇴를 진행하시겠습니까?", preferredStyle: .alert)
        let cancle = UIAlertAction(title: "취소", style: .cancel) {
            action in
            print("취소")
        }
        let deletion = UIAlertAction(title: "탈퇴 하기", style: .destructive){ action in
            print("탈퇴 눌렸습니다.")
            self.deleteUserAccount()
        }
        alert.addAction(cancle)
        alert.addAction(deletion)
        present(alert, animated: true)
    }
    
    func deleteUserData(completion: @escaping(Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).delete() { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                completion(false)
            }
            else {
                print("User data deleted successfully from Firestore")
                completion(true)
            }
        }
    }
    
    //애플 회원탈퇴
    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        deleteUserData { success in
            if success {
                user.delete { error in
                    if let error = error {
                        print("Error deleting user: \(error.localizedDescription)")
                        
                    }
                    else {
                        print("User account deleted successfully")
                        // 로그인 화면으로 이동
                        let loginViewController = LoginViewController()
                        self.navigationController?.pushViewController(loginViewController, animated: true)
                    }
                }
            }
            else {
                print("Failed to delete user data from Firestore")
            }
            
        }
    }
}

