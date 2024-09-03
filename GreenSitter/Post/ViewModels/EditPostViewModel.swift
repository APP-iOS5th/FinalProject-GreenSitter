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
    @Published var postImageURLs: [String] = []  // URL 배열로 변경
    @Published var selectedImageURLs: [String] = []  // URL 배열로 변경
    @Published var selectedImages: [UIImage] = []
    
    
    @Published var imageURLsToDelete: [String] = []
    
    @Published var selectedPost: Post
    private var firestoreManager = FirestoreManager()
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    init(selectedPost: Post) {
        self.selectedPost = selectedPost
        if let postImageURLs = selectedPost.postImages {
            self.selectedImageURLs = postImageURLs
        }
    }
    
    // 기존 이미지를 로드하는 함수
    func loadExistingImages(from urls: [String], completion: @escaping (String) -> Void) {
        let group = DispatchGroup()
        
        var processedURLs = Set<String>()
        
        for urlString in urls {
            group.enter()
            
            if processedURLs.contains(urlString) {
                group.leave()
                continue
            }
            
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer { group.leave() }
                
                guard let self = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    if !self.postImageURLs.contains(urlString) {
                        self.postImageURLs.append(urlString)
                        processedURLs.insert(urlString)
                    }
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion("Loaded!")
        }
    }
    
    // PHPicker에서 선택된 이미지를 Firebase Storage에 업로드하고 URL을 저장하는 함수
    func addSelectedImages(results: [PHPickerResult], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                            dispatchGroup.leave()
                            return
                        }
                        
                        let imageName = UUID().uuidString + ".jpg"
                        let storageRef = self?.storage.reference().child("post_images/\(imageName)")
                        
                        storageRef?.putData(imageData, metadata: nil) { (_, error) in
                            if let error = error {
                                print("Error uploading image: \(error.localizedDescription)")
                                dispatchGroup.leave()
                                return
                            }
                            
                            storageRef?.downloadURL { (url, error) in
                                if let url = url?.absoluteString {
                                    DispatchQueue.main.async {
                                        self?.selectedImageURLs.append(url)
                                        print("Added image URL to selectedImageURLs. Total count: \(self?.selectedImageURLs.count ?? 0)")
                                    }
                                }
                                dispatchGroup.leave()
                            }
                        }
                    } else {
                        print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished loading images. Total count: \(self.selectedImageURLs.count)")
            completion()
        }
    }
    
    // 선택된 이미지 URL을 삭제하는 함수
    func removeSelectedImage(at index: Int) {
        guard index >= 0 && index < selectedImageURLs.count else {
            print("Index out of bounds")
            return
        }
        selectedImageURLs.remove(at: index)
    }
    
    // 기존 이미지 URL을 삭제하는 함수
    func removeExistingImage(_ urlString: String) {
        print("Attempting to remove image with URL: \(urlString)")
        if let index = postImageURLs.firstIndex(of: urlString) {
            postImageURLs.remove(at: index)
            imageURLsToDelete.append(urlString)
            print("Image URL added to delete list: \(urlString)")
            print("Current imageURLsToDelete: \(imageURLsToDelete)")
        } else {
            print("Image URL not found in postImageURLs: \(urlString)")
        }
    }
    
    // 서버에서 이미지 삭제
    func deleteRemovedImages(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        
        print("Starting to delete removed images. Image URLs to delete: \(imageURLsToDelete)")
        
        for urlString in imageURLsToDelete {
            print(urlString)
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
    
    // 포스트 업데이트
    func updatePost(postTitle: String, postBody: String, completion: @escaping (Result<Post, Error>) -> Void) {
        // 삭제할 이미지 처리
        deleteRemovedImages { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                var allImageURLs = self.selectedPost.postImages ?? []
                allImageURLs = self.selectedImageURLs
                allImageURLs = allImageURLs.filter{ !self.imageURLsToDelete.contains($0) }
                
                // 기존의 포스트 데이터 업데이트
                let updatedPost = Post(
                    id: self.selectedPost.id,
                    enabled: true,
                    createDate: self.selectedPost.createDate,
                    updateDate: Date(),
                    userId: self.selectedPost.userId,
                    profileImage: self.selectedPost.profileImage,
                    nickname: self.selectedPost.nickname,
                    userLocation: self.selectedPost.userLocation,
                    userNotification: false,
                    userLevel: self.selectedPost.userLevel,
                    postType: self.selectedPost.postType,
                    postTitle: postTitle,
                    postBody: postBody,
                    postImages: allImageURLs,
                    postStatus: self.selectedPost.postStatus, // 수정 필요.
                    location: self.selectedPost.location
                )
                
                // Firestore에 업데이트
                do {
                    let postData = try Firestore.Encoder().encode(updatedPost)
                    self.db.collection("posts").document(self.selectedPost.id).setData(postData) { error in
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
    }
}
