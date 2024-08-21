//
//  LeavePlantListModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/20/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

extension LeavePlantListViewController {
    //MARK: - Post데이터 가져오기
    func fetchPostFirebase() {
        // 현재 로그인된 사용자의 userId 가져오기
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }

        // Firestore에서 특정 문서 가져오기
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting document: \(error)")
                return
            }

            // 문서가 존재하는지 확인
            if let document = document, document.exists {
                // 'post' 필드를 딕셔너리로 변환
                if let postData = document.data()?["post"] as? [String: Any] {
                    // postStatus 필드를 검사하여 "거래중"인 경우에만 처리
                    if let postStatus = postData["postStatus"] as? String, postStatus == "거래중" {
                        let postTitle = postData["postTitle"] as? String ?? "제목 없음"
                        let postBody = postData["postBody"] as? String ?? "본문 내용 없음"
                        let updateDateTimestamp = postData["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                        let updateDate = updateDateTimestamp.dateValue()
                        let postImages = postData["postImages"] as? [String] ?? []

                        // 데이터가 올바르게 불러와졌는지 출력해보기
                        print("Post Title: \(postTitle)")
                        print("Post Body: \(postBody)")
                        print("Post Status: \(postStatus)")
                        print("Update Date: \(updateDate)")
                        print("Post Images: \(postImages)")

                        // Post 객체 생성 및 배열에 추가
                        let post = Post(
                            id: document.documentID,
                            enabled: true,
                            createDate: Date(),
                            updateDate: updateDate,
                            userId: userId,
                            profileImage: "",  // 필요시 추가
                            nickname: "",      // 필요시 추가
                            userLocation: Location.seoulLocation, // 예시 위치
                            userNotification: false,
                            postType: .offeringToSitter,
                            postTitle: postTitle,
                            postBody: postBody,
                            postImages: postImages,
                            postStatus: .inTrade,
                            location: nil
                        )

                        // Post 배열에 추가
                        self.post.append(post)

                        // 테이블 뷰 업데이트
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Post status is not '거래중'.")
                    }
                } else {
                    print("Post data not found in document.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) // 한 번만 호출
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }
    
    
    
    //MARK: - 이미지 스토리지에서 이미지 파일 불러오기
    func loadImage(from gsURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let httpsURLString = convertToHttpsURL(gsURL: gsURL),
              let url = URL(string: httpsURLString) else {
            print("Invalid URL string: \(gsURL)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("이미지 다운로드 오류: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("이미지 변환 실패 또는 데이터가 없음")
                completion(nil)
                return
            }
            
            completion(image)
        }
        task.resume()
    }
}
