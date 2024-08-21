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
    // Firestore에서 postId와 일치하는 데이터 가져오기
    func fetchPostFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID is not available")
            return
        }
        
        // UserDefaults에서 저장된 postId 가져오기
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
                        
                        // postId가 저장된 savedPostId와 일치하는지 확인
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
    
    // Firestore에서 리뷰 데이터 가져오기
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
            
            if let reviewsData = document.data()?["reviews"] as? [String: Any] {
                // Initialize variables to safely decode
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
                
                // Initialize `self.reviews` with decoded data
                self.reviews = Review(id: reviewId, enabled: enabled, createDate: createDate, updateDate: updateDate, userId: userId, postId: postId, rating: rating, reviewText: reviewText, reviewImage: "reviewsData", selectedTexts: selectedTexts)
                
                print("Fetched Review: \(String(describing: self.reviews))")
                
                // postId가 savedPostId와 일치하는지 확인
                if postId == savedPostId {
                    self.selectedTexts = selectedTexts
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("Review post ID does not match saved post ID.")
                }
            } else {
                print("Reviews data not found")
            }
        }
    }

}
