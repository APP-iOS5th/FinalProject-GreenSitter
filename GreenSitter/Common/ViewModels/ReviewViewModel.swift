//임의로 다른사용자 id적용
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
            sender.backgroundColor = UIColor(named: "BGPrimary")
        } else {
            sender.backgroundColor = UIColor(named: "ComplementaryColor")
        }
        sender.isSelected = !isSelected
    }
    
    //MARK: - 완료
    @objc func completeButtonTap() {
        guard let creatorId = self.creatorId else {
            print("Creator ID가 없습니다.")
            return
        }
        // 현재 로그인한 사용자의 ID를 가져옵니다.
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }
        
        // 리뷰를 작성할 게시물 ID를 가져옵니다.
        guard let postId = postId else {
            print("No post ID found in review")
            return
        }
        
        // 사용자가 선택한 평점을 가져옵니다.
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
        
        // 평점에 따른 경험치 변화를 설정합니다.
        let expChange: Int
        switch rating {
        case .bad:
            expChange = -3
        case .average:
            expChange = 3
        case .good:
            expChange = 7
        }
        
        // 선택된 텍스트를 가져옵니다.
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
        
        // 새로운 리뷰 데이터 준비
        let newReview: [String: Any] = [
            "id": UUID().uuidString,
            "userId": userId,
            "enabled": true,
            "createDate": Timestamp(date: Date()), // Date를 Timestamp로 변환
            "updateDate": Timestamp(date: Date()), // Date를 Timestamp로 변환
            "postId": postId,
            "rating": rating.rawValue,
            "reviewText": reviewText ?? "",
            "selectedTexts": selectedTexts
        ]
        // 기존 리뷰를 가져옵니다.
        db.collection("users").document(creatorId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("작성자의 사용자 문서 가져오기 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("작성자의 사용자 문서가 존재하지 않거나, 문서 가져오기 실패")
                return
            }
            var reviews = document.data()?["reviews"] as? [[String: Any]] ?? []
            
            // 기존 리뷰를 찾아 업데이트하거나 새로운 리뷰를 추가합니다.
            if let existingIndex = reviews.firstIndex(where: { ($0["postId"] as? String) == postId }) {
                reviews[existingIndex] = newReview
            } else {
                reviews.append(newReview)
            }
            
            // 수정된 리뷰 배열로 사용자 문서를 업데이트합니다.
            self.db.collection("users").document(creatorId).updateData(["reviews": reviews]) { error in
                if let error = error {
                    print("사용자 문서에 리뷰 업데이트 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("리뷰가 성공적으로 사용자 문서에 업데이트되었습니다!")
                    
                    // 경험치 및 레벨 업데이트
                    self.updateUserExp(userId: creatorId, expChange: expChange)
                }
            }
        }
        
        // 리뷰 완료 후 사용자 프로필로 이동
        DispatchQueue.main.async {
            guard let userId = LoginViewModel.shared.user?.id else {
                print("User ID is not available")
                return
            }
            
            let aboutMeViewController = AboutMeViewController(userId: userId)
            self.navigationController?.pushViewController(aboutMeViewController, animated: true)
        }
    }
    
    
    
    // MARK: - 사용자 경험치 업데이트 함수
    func updateUserExp(userId: String, expChange: Int) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("사용자 문서 가져오기 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, var data = document.data() else {
                print("문서가 존재하지 않거나 문서 가져오기 실패")
                return
            }
            
            var currentExp = data["exp"] as? Int ?? 0
            currentExp += expChange
            
            // 레벨 업데이트 처리
            var levelPoint: Level = Level(rawValue: data["levelPoint"] as? String ?? "썩은 씨앗") ?? .rottenSeeds
            
            // 경험치가 0 이하로 떨어질 때의 처리
            while currentExp < 0 {
                let expNeededForCurrentLevel = 100 // 각 레벨마다 필요한 경험치
                
                // 경험치 부족분 계산
                let expNeededForPreviousLevel = expNeededForCurrentLevel + currentExp
                currentExp = expNeededForPreviousLevel
                
                // 레벨 변경
                levelPoint = levelPoint.previousLevel()
                
                
            }
            
            // 경험치가 100 이상으로 넘어가는 경우의 처리
            while currentExp >= 100 {
                let extraExp = currentExp - 100
                currentExp = extraExp
                levelPoint = levelPoint.nextLevel()
            }
            
            // 새로운 경험치와 레벨로 업데이트
            data["exp"] = currentExp
            data["levelPoint"] = levelPoint.rawValue
            
            self.db.collection("users").document(userId).updateData(data) { error in
                if let error = error {
                    print("사용자 문서에 경험치 및 레벨 업데이트 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("사용자 경험치와 레벨이 성공적으로 업데이트되었습니다!")
                }
            }
        }
    }
    
    
    
    
    // Firestore에서 받아온 데이터를 JSON으로 변환하기 전에 FIRTimestamp를 Date로 변환하는 유틸리티 함수
    func convertFirestoreData(_ data: [String: Any]) -> [String: Any] {
        var convertedData = [String: Any]()
        let dateFormatter = ISO8601DateFormatter()
        
        for (key, value) in data {
            if let timestamp = value as? Timestamp {
                convertedData[key] = dateFormatter.string(from: timestamp.dateValue())
            } else if let date = value as? Date {
                convertedData[key] = dateFormatter.string(from: date)
            } else if let stringValue = value as? String {
                convertedData[key] = stringValue
            } else if let boolValue = value as? Bool {
                convertedData[key] = boolValue ? 1 : 0
            } else if let intValue = value as? Int {
                convertedData[key] = intValue
            } else if let doubleValue = value as? Double {
                convertedData[key] = doubleValue
            } else if let arrayValue = value as? [Any] {
                convertedData[key] = arrayValue.compactMap { element in
                    if let elementDict = element as? [String: Any] {
                        return convertFirestoreData(elementDict)
                    } else {
                        return nil
                    }
                }
            } else if let nestedData = value as? [String: Any] {
                convertedData[key] = convertFirestoreData(nestedData)
            } else if let geoPoint = value as? GeoPoint {
                convertedData[key] = ["latitude": geoPoint.latitude, "longitude": geoPoint.longitude]
            } else {
                print("Unhandled data type for key: \(key), value: \(value)")
                convertedData[key] = value
            }
        }
        
        print("Converted Data: \(convertedData)")
        return convertedData
    }
    
    func fetchPostFirebase() {
        guard let postId = self.postId else {
            print("Post ID is not available")
            return
        }
        
        db.collection("posts").document(postId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("문서 가져오기 오류: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("문서가 존재하지 않거나 문서 가져오기 실패")
                return
            }
            
            // 문서 데이터 출력 (디버깅 용도)
            let documentData = document.data() ?? [:]
            
            // 문서가 예상 필드를 포함하는지 확인
            if let postStatus = documentData["postStatus"] as? String, postStatus == "거래완료" {
                let postTitle = documentData["postTitle"] as? String ?? "제목 없음"
                let postBody = documentData["postBody"] as? String ?? "본문 내용 없음"
                let userId = documentData["userId"] as? String ?? "id없음"
                let updateDateTimestamp = documentData["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                let createDate: Date = (documentData["createDate"] as? Timestamp)?.dateValue() ?? Date()
                let updateDate: Date = (documentData["updateDate"] as? Timestamp)?.dateValue() ?? Date()
                
                let postImages = documentData["postImages"] as? [String] ?? []
                
                // Post 객체 생성 및 업데이트
                self.review = Post(
                    id: postId,
                    enabled: true,
                    createDate: createDate,
                    updateDate: updateDate,
                    userId: userId,
                    profileImage: "",
                    nickname: "",
                    userLocation: Location.seoulLocation,
                    userNotification: false, userLevel: .flower,
                    postType: .offeringToSitter,
                    postTitle: postTitle,
                    postBody: postBody,
                    postImages: postImages,
                    postStatus: .completedTrade,
                    location: nil
                )
                
                // 테이블 뷰 업데이트
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Post status is not '거래완료'.")
            }
        }
    }
    
    //MARK: - 이미지 스토리지에서 이미지 파일 불러오기
    func loadImage(from gsURL: String, completion: @escaping (UIImage?) -> Void) {
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
