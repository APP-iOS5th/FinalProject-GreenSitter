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
    
    // 이미지 파이어스토리지에 저장
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
}
