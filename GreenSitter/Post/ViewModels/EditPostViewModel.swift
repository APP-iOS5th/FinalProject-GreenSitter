//
//  EditPostViewModel.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit
import PhotosUI

class EditPostViewModel: ObservableObject {
    @Published var postTitle: String
    @Published var postBody: String
    @Published var postImages: [UIImage] = []
    @Published var selectedImages: [UIImage] = []
    @Published var location: Location?
    @Published var imageURLsToDelete: [String] = []
    @Published var selectedPost: Post
    
    private var firestoreManager = FirestoreManager()
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    private let postId: String
    private let postType: PostType
    
    init(selectedPost: Post) {
        self.selectedPost = selectedPost
        self.postId = selectedPost.id
        self.postTitle = selectedPost.postTitle
        self.postBody = selectedPost.postBody
        self.location = selectedPost.location
        self.postType = selectedPost.postType
        
        
        // 초기화 시 기존 이미지를 로드
        if let postImageURLs = selectedPost.postImages {
            loadExistingImages(from: postImageURLs) {
                print("All images loaded")
            }
        }
        
        print("selectedPost: \(self.selectedPost)")
    }
    
    // 기존 이미지를 로드하는 함수
    func loadExistingImages(from urls: [String], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for urlString in urls {
            group.enter()
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer { group.leave() }
                
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data) else {
                    return
                }
                
                DispatchQueue.main.async {
                    image.accessibilityIdentifier = urlString
                    self.postImages.append(image)
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    // 새로 선택된 이미지를 추가하는 함수
    func addSelectedImages(results: [PHPickerResult], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
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
    
    // 선택된 이미지를 삭제하는 함수
    func removeSelectedImage(_ index: Int) {
        guard index >= 0 && index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    // 기존 이미지를 삭제하는 함수
    func removeExistingImage(_ urlString: String) {
        if let index = postImages.firstIndex(where: { $0.accessibilityIdentifier == urlString }) {
            postImages.remove(at: index)
            imageURLsToDelete.append(urlString)
        }
    }
    
    // 새 이미지를 업로드하는 함수
    private func uploadNewImages(completion: @escaping (Result<[String], Error>) -> Void) {
        var imageURLs: [String] = []
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                group.leave()
                continue
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
    
    // 삭제할 이미지를 처리하는 함수
    private func deleteRemovedImages(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        
        for urlString in imageURLsToDelete {
            group.enter()
            let storageRef = storage.reference(forURL: urlString)
            storageRef.delete { error in
                if let error = error {
                    group.leave()
                    completion(.failure(error))
                    return
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(()))
        }
    }
    
    // 포스트를 업데이트하는 함수
    func updatePost(completion: @escaping (Result<Post, Error>) -> Void) {
        deleteRemovedImages { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.uploadNewImages { result in
                    switch result {
                    case .success(let newImageURLs):
                        var allImageURLs = self.selectedPost.postImages ?? []
                        allImageURLs.append(contentsOf: newImageURLs)
                        
                        let updatedPost = Post(
                            id: self.postId,
                            enabled: true,
                            createDate: self.selectedPost.createDate,
                            updateDate: Date(),
                            userId: self.selectedPost.userId,
                            profileImage: self.selectedPost.profileImage,
                            nickname: self.selectedPost.nickname,
                            userLocation: self.location ?? Location.seoulLocation,
                            userNotification: false,
                            userLevel: self.selectedPost.userLevel,
                            postType: self.postType,
                            postTitle: self.postTitle,
                            postBody: self.postBody,
                            postImages: allImageURLs,
                            postStatus: .beforeTrade,
                            location: self.location
                        )
                        
                        do {
                            let postData = try Firestore.Encoder().encode(updatedPost)
                            self.db.collection("posts").document(self.postId).setData(postData) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(updatedPost))
                                }
                            }
                        } catch {
                            completion(.failure(error))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
