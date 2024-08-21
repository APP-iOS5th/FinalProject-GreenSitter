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
    
    func updateButtonColors(selectedTexts: [String]) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ReceiveReviewTableViewCell else {
            return
        }
        
        let buttonTextMapping: [(UIButton, String)] = [
            (cell.row1Button, "시간 약속을 잘 지켜요!"),
            (cell.row2Button, "의사소통이 원활해요!"),
            (cell.row3Button, "신뢰할 수 있어요!"),
            (cell.row4Button, "매우 친절해요!")
        ]
        
        for (button, text) in buttonTextMapping {
            if selectedTexts.contains(text) {
                button.backgroundColor = UIColor(named: "ComplementaryColor")
            } else {
                button.backgroundColor = .white
            }
        }
    }
    
    func fetchPostFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        let savedPostId = UserDefaults.standard.string(forKey: "savedPostId") ?? ""
        print("Saved Post ID: \(savedPostId)")
        
        let postRef = db.collection("users").document(userId)
        postRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                if let postData = document.data()?["post"] as? [String: Any] {
                    if let postStatus = postData["postStatus"] as? String, postStatus == "거래완료" {
                        let postTitle = postData["postTitle"] as? String ?? "제목 없음"
                        let postBody = postData["postBody"] as? String ?? "본문 내용 없음"
                        let updateDateTimestamp = postData["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                        let updateDate = updateDateTimestamp.dateValue()
                        let postImages = postData["postImages"] as? [String] ?? []
                        let postId = postData["id"] as? String ?? ""
                        
                        print("Post Title: \(postTitle)")
                        print("Post Body: \(postBody)")
                        print("Post Status: \(postStatus)")
                        print("Update Date: \(updateDate)")
                        print("Post Images: \(postImages)")
                        print("Post id: \(postId)")
                        
                        if postId == savedPostId {
                            self.post = Post(
                                id: postId,
                                enabled: true,
                                createDate: Date(),
                                updateDate: updateDate,
                                userId: userId,
                                profileImage: "",
                                nickname: "",
                                userLocation: Location.seoulLocation,
                                userNotification: false,
                                postType: .offeringToSitter,
                                postTitle: postTitle,
                                postBody: postBody,
                                postImages: postImages,
                                postStatus: .completedTrade,
                                location: nil
                            )
                            
                            // 데이터가 설정된 후 테이블 뷰를 리로드합니다.
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            print("Post ID does not match saved Post ID.")
                        }
                    } else {
                        print("Post status is not '거래완료'.")
                    }
                } else {
                    print("Post data not found in document.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    
//    func fetchReviewFirebase() {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User ID is not available")
//            return
//        }
//        
//        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error getting document: \(error)")
//                return
//            }
//            if let document = document, document.exists {
//                let data = document.data()
//                let reviewId = data?["id"] as? String ?? ""
//                let userId = data?["userId"] as? String ?? ""
//                let enabled = data?["enabled"] as? Bool ?? false
//                let createDate = (data?["createDate"] as? Timestamp)?.dateValue() ?? Date()
//                let updateDate = (data?["updateDate"] as? Timestamp)?.dateValue() ?? Date()
//                let postId = data?["postId"] as? String ?? ""
//                let ratingRawValue = data?["rating"] as? String ?? "average"
//                let reviewText = data?["reviewText"] as? String ?? ""
//                let selectedTexts = data?["selectedTexts"] as? [String] ?? []
//                
//                
//                // Rating 열거형 정의
//                enum Rating: String {
//                    case bad, average, good
//                }
//                
//                let rating: Rating
//                switch ratingRawValue {
//                case "bad":
//                    rating = .bad
//                case "good":
//                    rating = .good
//                default:
//                    rating = .average
//                }
//                
//                // 리뷰 데이터 출력
//                print("Review ID: \(reviewId)")
//                print("User ID: \(userId)")
//                print("Enabled: \(enabled)")
//                print("Create Date: \(createDate)")
//                print("Update Date: \(updateDate)")
//                print("Post ID: \(postId)")
//                print("Rating: \(rating.rawValue)")
//                print("Review Text: \(reviewText)")
//                print("Selected Texts: \(selectedTexts)")
//              
//            
//                
//
//                
//                if let postImages = data?["postImages"] as? [String], !postImages.isEmpty {
//                    let imageURL = postImages.first!
//                    // 이미지 다운로드 및 설정은 이후 단계에서 다룹니다.
//                }
//                
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData() // 데이터를 업데이트한 후 테이블 뷰를 리로드합니다.
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
//    
   
}
