//
//  ReceiveReviewViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

extension ReceiveReviewViewController {
    // MARK: - post정보 불러오기
    func fetchPostFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }

        db.collection("posts").whereField("userId", isEqualTo: userId).whereField("postType", isEqualTo: "새싹돌봄이 찾습니다").whereField("postStatus", isEqualTo: "거래완료").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            // 문서가 존재하는지 확인
            for document in documents {
                let postData = document.data()
                
                let postStatus = PostStatus(rawValue: postData["postStatus"] as? String ?? "") ?? .completedTrade
                let postTitle = postData["postTitle"] as? String ?? "제목 없음"
                let postBody = postData["postBody"] as? String ?? "본문 내용 없음"
                let updateDateTimestamp = postData["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                let updateDate = updateDateTimestamp.dateValue()
                let postImages = postData["postImages"] as? [String] ?? []
                
                // 데이터가 올바르게 불러와졌는지 출력해보기
                print("Post Title: \(postTitle)")
                print("Post Body: \(postBody)")
                
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
                    userLevel: .rottenSeeds,
                    postType: .lookingForSitter,
                    postTitle: postTitle,
                    postBody: postBody,
                    postImages: postImages,
                    postStatus: postStatus,
                    location: nil
                )
                self.post.append(post)
                // 테이블 뷰 업데이트
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - 리뷰데이터 정보 불러오기
    func fetchReviewFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        // UserDefaults에서 저장된 postId 가져오기
        let savedPostId = UserDefaults.standard.string(forKey: "savedPostId") ?? ""
        print("Saved Post ID: \(savedPostId)")
        
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            
            if let reviewsArray = document.data()?["reviews"] as? [[String: Any]] { // 배열로 처리
                for reviewsData in reviewsArray { // 배열 순회
                    let reviewId = reviewsData["id"] as? String ?? ""
                    let userId = reviewsData["userId"] as? String ?? ""
                    let enabled = reviewsData["enabled"] as? Bool ?? false
                    let createDate = (reviewsData["createDate"] as? Timestamp)?.dateValue() ?? Date()
                    let updateDate = (reviewsData["updateDate"] as? Timestamp)?.dateValue() ?? Date()
                    let postId = reviewsData["postId"] as? String ?? ""
                    let reviewImage = reviewsData["reviewImage"] as? [String] ?? []
                    
                    // Safely decode `rating` to `Rating` enum
                    let ratingRawValue = reviewsData["rating"] as? String ?? "average"
                    let rating = Rating(rawValue: ratingRawValue) ?? .average
                    
                    let reviewText = reviewsData["reviewText"] as? String
                    let selectedTexts = reviewsData["selectedTexts"] as? [String] ?? []
                    
                    // 리뷰 데이터를 Review 객체에 저장
                    let review = Review(id: reviewId, enabled: enabled, createDate: createDate, updateDate: updateDate, userId: userId, postId: postId, rating: rating, reviewText: reviewText, reviewImage: "reviewImage", selectedTexts: selectedTexts)
                    
                    print("Fetched Review: \(String(describing: review))")
                    
                    // postId가 savedPostId와 일치하는지 확인
                    if postId == savedPostId {
                        self.selectedTexts = selectedTexts
                        self.reviews = review  // self.reviews에 저장
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Review post ID does not match saved post ID.")
                    }
                }
            } else {
                print("Reviews data not found")
            }
        }
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
    
    func convertToHttpsURL(gsURL: String) -> String? {
        let baseURL = "https://firebasestorage.googleapis.com/v0/b/greensitter-6dedd.appspot.com/o/"
        let encodedPath = gsURL
            .replacingOccurrences(of: "gs://greensitter-6dedd.appspot.com/", with: "")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) // 한 번만 호출
        return baseURL + (encodedPath ?? "") + "?alt=media"
    }
    
    func loadPostImages(from imageURLs: [String]) {
        let imageView = UIImageView()

        if let firstImageURL = imageURLs.first {
            loadImage(from: firstImageURL) { [weak self] image in
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    //MARK: - 이미지 스토리지에서 이미지 파일 불러오기
    func postLoadImage(from gsURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: gsURL) else {
            print("Invalid URL string: \(gsURL)")
            completion(nil)
            return
        }
        
        print("Fetching image from URL: \(url)") // URL 디버깅
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 응답의 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // 데이터 크기 및 내용 확인
            print("Image data size: \(data.count) bytes")
            
            // 데이터의 일부를 문자열로 변환하여 출력 (디버깅 용도)
            if let dataString = String(data: data, encoding: .utf8) {
                print("Data received: \(dataString.prefix(1000))") // 첫 1000바이트만 출력
            } else {
                print("Data is not a valid UTF-8 string")
            }
            
            // UIImage 객체 생성 시도
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data")
                completion(nil)
                return
            }
            
            completion(image)
        }
        task.resume()
    }
}
