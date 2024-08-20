//
//  ReviewViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension ReviewViewController {
    
    //MARK: - 나쁨, 보통, 좋음 리뷰
    @objc func selectButtonTap(_ sender: UIButton) {
        if let previousButton = selectedRatingButton {
            previousButton.layer.borderColor = UIColor.clear.cgColor
            previousButton.layer.borderWidth = 0
        }
        
        // 선택된 버튼에 테두리 설정
        sender.layer.borderColor = UIColor(named: "ComplementaryColor")?.cgColor ?? UIColor.blue.cgColor
        sender.layer.borderWidth = 2.0
        sender.isSelected = true
        selectedRatingButton = sender
        
        printRating(for: sender)
    }
    
    private func printRating(for button: UIButton) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ReviewSendTableViewCell else { return }
        
        if button == cell.badButton {
            print("Bad selected")
        } else if button == cell.averageButton {
            print("Average selected")
        } else if button == cell.goodButton {
            print("Good selected")
        }
    }

    //MARK: - 텍스트 리뷰
    @objc func slectTextButtonTap(_ sender: UIButton) {
        let isSelected = sender.isSelected
        
        if isSelected {
            // 선택 해제시 기본 상태로 복구
            sender.backgroundColor = UIColor.white
        } else {
            sender.backgroundColor = UIColor(named: "ComplementaryColor")
        }
        sender.isSelected = !isSelected
    }
    
    //MARK: - 완료
    @objc func completeButtonTap() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }
        
//        guard let postId = review?.postId else {
//            print("No post ID found in review")
//            return
//        }
        let postId = "some-hardcoded-post-id"  // 임시로 설정한 postId

        // Get the rating
        let rating: Rating = {
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ReviewSendTableViewCell else { return .average }
            if let selectedButton = selectedRatingButton {
                if selectedButton == cell.badButton {
                    return .bad
                } else if selectedButton == cell.averageButton {
                    return .average
                } else if selectedButton == cell.goodButton {
                    return .good
                }
            }
            return .average
        }()
        
        // Get the selected texts
        var selectedTexts = [String]()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ReviewSendTableViewCell {
            if cell.row1Button.isSelected {
                selectedTexts.append(cell.row1Button.titleLabel?.text ?? "")
            }
            if cell.row2Button.isSelected {
                selectedTexts.append(cell.row2Button.titleLabel?.text ?? "")
            }
            if cell.row3Button.isSelected {
                selectedTexts.append(cell.row3Button.titleLabel?.text ?? "")
            }
            if cell.row4Button.isSelected {
                selectedTexts.append(cell.row4Button.titleLabel?.text ?? "")
            }
        }
        let reviewText = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ReviewSendTableViewCell)?.reviewTextField.text
        
        // Prepare data to update user document
        let newReview: [String: Any] = [
            "reviews": [
                "id": UUID().uuidString,
                "enabled": true,
                "createDate": Timestamp(date: Date()),
                "updateDate": Timestamp(date: Date()),
                "postId": postId,
                "rating": rating.rawValue,
                "reviewText": reviewText ?? "",
                "selectedTexts": selectedTexts
            ]
        ]
        
        // Update user document with new review data
        db.collection("users").document(userId).setData(newReview, merge: true) { error in
            if let error = error {
                print("Error writing review to Firestore: \(error)")
            } else {
                print("Review successfully written!")
            }
        }
        //게시물 작성자파이어베이스에 저장
        db.collection("posts").document(postId).getDocument { document, error in
            if let document = document, document.exists {
                let postData = document.data()
                if let creatorId = postData?["creatorId"] as? String {
                    // Save the review to the post creator's document
                    let reviewRef = self.db.collection("users").document(creatorId).collection("review").document(UUID().uuidString) // create a new document in the 'reviews' subcollection
                    reviewRef.setData(newReview) { error in
                        if let error = error {
                            print("Error writing review to post creator's Firestore document: \(error)")
                        } else {
                            print("Review successfully written to post creator's document!")
                        }
                    }
                } else {
                    print("Creator ID not found in the post document")
                }
            } else {
                print("Post document does not exist")
            }
        }
    }
    
    
}
