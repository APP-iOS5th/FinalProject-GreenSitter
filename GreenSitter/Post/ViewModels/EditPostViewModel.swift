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
    @Published var addedImages: [UIImage] = []
    
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
    // 이미지를 추가할 때 배열을 업데이트하는 함수
    func addSelectedImages(results: [PHPickerResult], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        // 이미지를 리사이징 후 업로드
                        let resizedImage = self?.resizeImage(image: image, targetSize: CGSize(width: 190, height: 200))
                        
                        guard let imageData = resizedImage?.jpegData(compressionQuality: 0.5) else {
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
                                        // 배열에 추가하기 전에 현재 배열 상태를 확인하고 업데이트
                                        self?.selectedImageURLs.append(url)
                                        print("Added image URL. Total count: \(self?.selectedImageURLs.count ?? 0)")
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
        
        // 모든 작업이 끝난 후 배열 업데이트
        dispatchGroup.notify(queue: .main) {
            print("Finished loading images. Total count: \(self.selectedImageURLs.count ?? 0)")
            completion()
        }
    }
    
    // 이미지를 삭제하고 배열을 업데이트하는 함수
    func removeSelectedImage(at index: Int) {
        guard index >= 0 && index < selectedImageURLs.count else {
            print("Index out of bounds")
            return
        }
        // 배열에서 이미지 삭제
        selectedImageURLs.remove(at: index)
        print("Removed image at index \(index). Current count: \(selectedImageURLs.count)")
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
    func deleteRemovedImages(completion: @escaping (Result<[String], Error>) -> Void) {
        var imageURLs: [String] = []
        let group = DispatchGroup()
        
        for image in addedImages {
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
            completion(.success((imageURLs)))
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // 비율을 유지하면서 최소 비율로 조정
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // 새로운 사이즈로 리사이즈
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    // 포스트 업데이트
    func updatePost(postTitle: String, postBody: String, completion: @escaping (Result<Post, Error>) -> Void) {
        // 삭제할 이미지 처리
        deleteRemovedImages { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageUrls):
                var allImageURLs = self.selectedPost.postImages ?? []
                allImageURLs = self.selectedImageURLs
                allImageURLs = allImageURLs.filter{ !self.imageURLsToDelete.contains($0) }
                allImageURLs += imageUrls
                
                // 기존의 포스트 데이터 업데이트
                let updatedPost = Post(
                    id: self.selectedPost.id,
                    enabled: true,
                    createDate: self.selectedPost.createDate,
                    updateDate: Date(),
                    recipientId: self.selectedPost.recipientId,
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
