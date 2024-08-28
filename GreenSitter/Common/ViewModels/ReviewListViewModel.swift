//
//  ReviewListViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension ReviewListViewController {
    //MARK: - Post데이터 가져오기
    func fetchPostFirebase() {
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
                if let postData = document.data()?["post"] as? [String: Any] {
                    if let postStatus = postData["postStatus"] as? String, postStatus == "거래완료",
                       let isReviewed = postData["isReviewed"] as? Bool, !isReviewed {  // 리뷰되지 않은 포스트만 처리
                        let postTitle = postData["postTitle"] as? String ?? "제목 없음"
                        let postBody = postData["postBody"] as? String ?? "본문 내용 없음"
                        let updateDateTimestamp = postData["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                        let updateDate = updateDateTimestamp.dateValue()
                        let postImages = postData["postImages"] as? [String] ?? []

                        let post = Post(
                            id: document.documentID,
                            enabled: true,
                            createDate: Date(),
                            updateDate: updateDate,
                            userId: userId,
                            profileImage: "",
                            nickname: "",
                            userLocation: Location.seoulLocation,
                            userNotification: false,
                            userLevel: .flower,
                            postType: .offeringToSitter,
                            postTitle: postTitle,
                            postBody: postBody,
                            postImages: postImages,
                            postStatus: .completedTrade,
                            location: nil
                        )

                        self.post.append(post)

                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Post status is not '거래완료' or post has been reviewed.")
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
