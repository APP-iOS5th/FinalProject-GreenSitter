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
import Combine

extension AboutMeViewController {
    //MARK: - 자기소개 수정하기
    @objc func editButtonTapped() {
        let selfIntroduction = SelfIntroductionViewController()
        present(selfIntroduction, animated: true)
        
        if let presentationController = selfIntroduction.presentationController as? UISheetPresentationController {
            presentationController.detents = [
                UISheetPresentationController.Detent.custom { _ in
                    return 400
                }
            ]
            presentationController.preferredCornerRadius = 20 // 모서리 둥글기 설정 (선택 사항)
        }
    }
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
                let aboutMe = data?["aboutMe"] as? String ?? "자기 소개를 입력해주세요"
                let levelPoint = data?["levelPoint"] as? String ?? ""
                print("Fetched levelPoint: \(levelPoint)")
                print("자기소개: \(aboutMe)")
                
                self.user?.aboutMe = aboutMe
                
                // location 필드에서 address를 가져오기
                if let location = data?["location"] as? [String: Any],
                   let locationAddress = location["address"] as? String {
                    self.user?.location.address = locationAddress
                    
                    // UI 업데이트: locationLabel에 주소 표시
                    DispatchQueue.main.async {
                        self.locationLabel.text = locationAddress
                    }
                } else {
                    // location 정보가 없을 때 기본값 설정
                    self.locationLabel.text = "주소 없음"
                }
                // 프로필 이미지 로드
                if !profileImage.isEmpty {
                    self.loadProfileImage(from: profileImage)
                }
                
                // UI 업데이트
                DispatchQueue.main.async {
                    self.nicknameLabel.text = nickname
                    self.levelLabel.text = levelPoint
                    self.tableView.reloadData()
                }
            } else {
                print("Document does not exist")
            }
        }
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
                self.profileImage.image = image
            }
        }
        task.resume()
    }
    //MARK: - gs:// URL을 https:// URL로 변환
    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) // 한 번만 호출
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }
    
    
}
