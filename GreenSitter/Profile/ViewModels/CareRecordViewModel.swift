import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

extension CareRecordViewController {
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
                let data = document.data()
                let postTitle = data?["postTitle"] as? String ?? "제목 없음"
                let postBody = data?["postBody"] as? String ?? "본문 내용 없음"
                let postStatus = data?["postStatus"] as? String ?? "거래 상태 없음"
                let updateDateTimestamp = data?["updateDate"] as? Timestamp ?? Timestamp(date: Date())
                let updateDate = updateDateTimestamp.dateValue()
                let postImages = data?["postImages"] as? [String] ?? []
                
                let post = Post(id: "some-hardcoded-post-id", enabled: true, createDate: Date(), updateDate: updateDate, userId: userId, profileImage: "", nickname: "", userLocation: Location.seoulLocation, userNotification: false, postType: .offeringToSitter, postTitle: postTitle, postBody: postBody, postImages: postImages, postStatus: .beforeTrade, location: nil)
                
                if let postImages = data?["postImages"] as? [String], !postImages.isEmpty {
                    let imageURL = postImages.first!
                    // 이미지 다운로드 및 설정은 이후 단계에서 다룹니다.
                }
                
                self.post.append(post)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() // 데이터를 업데이트한 후 테이블 뷰를 리로드합니다.
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
