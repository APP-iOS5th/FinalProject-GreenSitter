//
//  AddCareProviderViewModel.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit
import PhotosUI // PHPickerResult를 사용하기 위해 추가

class AddPostViewModel: ObservableObject {
    @Published var postTitle: String = ""
    @Published var postBody: String = ""
    @Published var postImages: [UIImage] = []
    @Published var selectedImages: [UIImage] = []
    @Published var location: Location? = nil
    
    private var firestoreManager = FirestoreManager()
    private let postType: PostType
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    init(postType: PostType) {
        self.postType = postType
    }
    
    // 이미지 추가 메서드
    func addImage(_ image: UIImage) {
        postImages.append(image)
    }

    // 선택된 이미지를 추가하는 메서드
    func addSelectedImages(results: [PHPickerResult], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self?.selectedImages.append(image)
                        }
                    } else {
                        print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    // 이미지 제거 메서드
    func removeImage(_ index: Int) {
        guard index >= 0 && index < postImages.count else { return }
        postImages.remove(at: index)
    }
    
    // 선택된 이미지를 제거하는 메서드
    func removeSelectedImage(_ index: Int) {
        guard index >= 0 && index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    // 이미지 업로드 메서드
    private func uploadImages(completion: @escaping (Result<[String], Error>) -> Void) {
        var imageURLs: [String] = []
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                group.leave()
                completion(.failure(NSError(domain: "Image conversion failed", code: 0, userInfo: nil)))
                return
            }
            
            let imageName = UUID().uuidString + ".jpg"
            let storageRef = storage.reference().child("post_images/\(imageName)")
            
            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    group.leave()
                    completion(.failure(error))
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        group.leave()
                        completion(.failure(error))
                        return
                    }
                    
                    if let imageURL = url?.absoluteString {
                        imageURLs.append(imageURL)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(imageURLs))
        }
    }
    
    // 게시물 저장 메서드
    func savePost(postTitle: String, postBody: String, completion: @escaping (Result<Post, Error>) -> Void) {
        uploadImages { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageURLs):
                let post = Post(
                    id: UUID().uuidString,
                    enabled: true,
                    createDate: Date(),
                    updateDate: Date(),
                    
                    userId: "currentUserId",  // 실제 사용자 정보로 대체해야 함
                    profileImage: "currentProfileImage",  // 실제 프로필 이미지로 대체해야 함
                    nickname: "currentNickname",  // 실제 닉네임으로 대체해야 함
                    userLocation: self.location ?? Location.seoulLocation,  // 기본 위치를 서울로 설정
                    userNotification: false,
                    
                    postType: self.postType,
                    postTitle: postTitle,
                    postBody: postBody,
                    postImages: imageURLs,
                    postStatus: .beforeTrade,
                    location: self.location
                )
                
                do {
                    let postData = try Firestore.Encoder().encode(post)
                    self.db.collection("posts").document(post.id).setData(postData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(post))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}



