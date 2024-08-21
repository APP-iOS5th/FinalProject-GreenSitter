//
//  FireStorageManager.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/21/24.
//

import UIKit
import FirebaseStorage

class FirestorageManager {
    private let storage = Storage.storage()
    
    // 이미지 파이어베이스 스토리지에 저장
    func saveImage(data: Data) async throws -> String {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let storageRef = storage.reference()
        let path = "imagesForChat/\(UUID().uuidString).jpeg"
        let returnedMetadata = try await storageRef.child(path).putDataAsync(data, metadata: metadata)
        
        guard let returnedPath = returnedMetadata.path else {
            throw URLError(.badServerResponse)
        }
        
        return returnedPath
    }
    
    // UIImage -> Data 변환
    func imageToData(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 1.0) ?? nil
    }
    
    // 파이어베이스 스토리지에서 이미지 가져오기
    func loadImage(imagePath: String) async throws -> UIImage {
        let storageRef = storage.reference()
        let imageRef = storageRef.child(imagePath)
        
        return try await withCheckedThrowingContinuation { continuation in
            imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let image = UIImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    let defaultImage = UIImage(systemName: "photo")!
                    continuation.resume(returning: defaultImage)
                }
            }
        }
    }

}
