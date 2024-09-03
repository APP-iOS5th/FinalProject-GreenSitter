//
//  FireStorageManager.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/21/24.
//

import UIKit
import FirebaseStorage
import Kingfisher

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
        var compressionQuality: CGFloat = 1.0
        let minCompressionQuality: CGFloat = 0.1 // 너무 낮은 품질은 피하기 위해 최소 값 설정
        let step: CGFloat = 0.1

        var imageData: Data? = image.jpegData(compressionQuality: compressionQuality)
        
        let maxSize = 4 * 1024 * 1024
        // 이미지가 maxSize를 초과할 경우 compressionQuality를 줄여나감
        while let data = imageData, data.count > maxSize, compressionQuality > minCompressionQuality {
            compressionQuality -= step
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        // 최종적으로 압축된 이미지 데이터를 반환
        return imageData
    }

    
    // 파이어베이스 스토리지에서 이미지 가져오기
//    func loadImage(imagePath: String) async throws -> UIImage {
//        let storageRef = storage.reference()
//        let imageRef = storageRef.child(imagePath)
//        
//        let data = try await imageRef.data(maxSize: 4 * 1024 * 1024)
//        let photoImage = UIImage(systemName: "photo")!
//        return UIImage(data: data) ?? photoImage
//    }
    func loadImage(imageURL: URL, imageSize: CGFloat, imageView: inout UIImageView, completion: (() -> Void)? = nil ) {
        let processor = DownsamplingImageProcessor(size: CGSize(width: imageSize, height: imageSize))
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageURL,
            placeholder: nil,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ],
            completionHandler: { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        completion?()
                    }
                case .failure(let error):
                    print("Failed to load Image: \(error.localizedDescription)")
                }
            }
        )
    }

}
