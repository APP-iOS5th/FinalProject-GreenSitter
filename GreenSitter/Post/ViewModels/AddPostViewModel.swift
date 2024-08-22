//
//  AddCareProviderViewModel.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import Foundation
import FirebaseFirestore

class AddPostViewModel: ObservableObject {
//    @Published var postTitle: String = ""
//    @Published var postBody: String = ""
    @Published var postImages: [String] = []
    @Published var location: Location? = nil
    
    private var postType: PostType
    
    init(postType: PostType) {
        self.postType = postType
    }
    
    func savePost(postTitle: String, postBody: String, completion: @escaping (Result<Post, Error>) -> Void) {
        // Post 객체를 생성
        let post = Post(
            id: UUID().uuidString,
            enabled: true,
            createDate: Date(),
            updateDate: Date(),
            
            userId: "currentUserId", // 현재 사용자의 ID를 넣어주세요.
            profileImage: "currentProfileImage", // 현재 사용자의 프로필 이미지를 넣어주세요.
            nickname: "currentNickname", // 현재 사용자의 닉네임을 넣어주세요.
            userLocation: Location.seoulLocation, // 사용자의 실제 위치를 넣어주세요.
            userNotification: false, // 기본값을 설정하거나 사용자의 설정을 불러오세요.
            
            postType: postType,
            postTitle: postTitle,
            postBody: postBody,
            postImages: postImages,
            postStatus: .beforeTrade,
            location: Location.seoulLocation
        )
        
        let db = Firestore.firestore()
        
        do {
            let postData = try Firestore.Encoder().encode(post)
            db.collection("posts").document(post.id).setData(postData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(post))
                }
            }
        } catch {
            completion(.failure(error))
        }
        
    }
}
