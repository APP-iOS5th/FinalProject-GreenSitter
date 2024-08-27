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
import GoogleSignIn

extension ProfileViewController {
    
    //MARK: - 파이어베이스 데이터 불러오기
    func fetchUserFirebase() {
        let loginViewModel = LoginViewModel.shared
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("로그인된 사용자가 없습니다.")
            return
        }
        
        loginViewModel.firebaseFetch(docId: currentUserID) {}
        
        if let profileImageURL = loginViewModel.user?.profileImage {
            loginViewModel.loadProfileImage(from: profileImageURL) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.imageButton.setImage(image, for: .normal)
                    print("Profile image successfully set to button.")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
    

    // MARK: - gs:// URL을 https:// URL로 변환
    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }
    
    // MARK: - 이미지 파일 스토리지에서 이미지 파일 불러오기
    func loadProfileImage(from gsURL: String) {
        guard let httpsURLString = convertToHttpsURL(gsURL: gsURL),
              let url = URL(string: httpsURLString) else {
            print("Invalid URL string after conversion: \(gsURL)")
            return
        }
        
        print("Fetching image from URL: \(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode)")
                    return
                }
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("No data received or failed to convert data to UIImage")
                return
            }
            
            DispatchQueue.main.async {
                self.imageButton.setImage(image, for: .normal)
                print("Profile image successfully set to button.")
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
            self.viewWillAppear(true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    //MARK: - 구글 재인증
    func reauthenticateWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            completion(false)
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                print("Google sign-in error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let authentication = signInResult?.user else {
                print("Google authentication failed.")
                completion(false)
                return
            }
            
            guard let idToken = authentication.idToken?.tokenString else {
                print("Failed to retrieve ID token.")
                completion(false)
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)

            currentUser.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Re-authentication with Google failed: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Re-authentication with Google succeeded.")
                    completion(true)
                }
            }
        }
    }

    
    //MARK: - Apple재인증
    func reauthenticateWithApple(completion: @escaping (Bool) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(false)
                return
            }

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            
            // completion 클로저를 저장합니다.
            self.currentReauthCompletion = completion
            
            authorizationController.performRequests()
        }

        // ASAuthorizationControllerDelegate 메서드
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                print("Apple ID Credential 또는 identity token이 없습니다.")
                currentReauthCompletion?(false)
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: "")

            Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Apple로 재인증 실패: \(error.localizedDescription)")
                    self.currentReauthCompletion?(false)
                } else {
                    print("Apple로 재인증 성공.")
                    self.currentReauthCompletion?(true)
                }
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Apple 로그인 에러: \(error.localizedDescription)")
            currentReauthCompletion?(false)
        }

        // ASAuthorizationControllerPresentationContextProviding 메서드
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
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
    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        let providerData = user.providerData.first
        let providerID = providerData?.providerID
        
        let reauthenticate: (@escaping (Bool) -> Void) -> Void
        
        if providerID == "google.com" {
            reauthenticate = reauthenticateWithGoogle
        } else if providerID == "apple.com" {
            reauthenticate = reauthenticateWithApple
        } else {
            print("Unsupported provider: \(providerID ?? "unknown")")
            return
        }
        
        reauthenticate { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.deleteUserData { success in
                    if success {
                        user.delete { error in
                            if let error = error {
                                print("Error deleting user: \(error.localizedDescription)")
                            } else {
                                print("User account deleted successfully")
                                self.viewWillAppear(true)
                            }
                        }
                    } else {
                        print("Failed to delete user data from Firestore")
                    }
                }
            } else {
                print("Re-authentication failed. Please try again.")
            }
        }
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

}

