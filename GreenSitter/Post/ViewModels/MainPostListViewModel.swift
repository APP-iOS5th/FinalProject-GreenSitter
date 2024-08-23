//
//  MainPostListViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/22/24.
//

import Foundation
import FirebaseFirestore
import Combine

class MainPostListViewModel {
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    @Published var filteredPosts: [Post] = []

    // Haversine 공식을 사용하여 두 위치 간의 거리 계산 (단위: 미터)
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm: Double = 6371.0

        let dLat = (lat2 - lat1).degreesToRadians
        let dLon = (lon2 - lon1).degreesToRadians

        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1.degreesToRadians) * cos(lat2.degreesToRadians) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusKm * c * 1000 // 결과를 미터로 반환
    }
    
    // TODO: Date 에 따라 정렬해서 가져오기
    func fetchPostsByCategoryAndLocation(for category: String) {
        guard let postType = PostType(rawValue: category) else {
            filteredPosts = []
            return
        }

        db.collection("posts")
            .whereField("postType", isEqualTo: postType.rawValue)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    self?.filteredPosts = []
                    return
                }

                self?.filteredPosts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Post.self)
                } ?? []
            }
    }
    
    // 유저 위치 정보(옵셔널) 만 받기
    func fetchPostsWithin3Km(userLocation: Location?) {
        db.collection("posts")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    self?.filteredPosts = []
                    return
                }
                let posts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Post.self)
                } ?? []
                
                // 사용자 위치를 기준으로 3km 이내의 게시물 필터링 및 최신 업데이트 순으로 정렬
                self?.filteredPosts = posts.filter { post in
                    let distance = self?.calculateDistance(
                        lat1: userLocation?.latitude ?? Location.seoulLocation.latitude,    // 위치 정보 파라미터 값 안받으면 기본 값은 서울 시청!
                        lon1: userLocation?.longitude ?? Location.seoulLocation.longitude,
                        lat2: post.userLocation.latitude,
                        lon2: post.userLocation.longitude
                    ) ?? Double.greatestFiniteMagnitude
                    
                    return distance <= 3000 // 3km 이내의 게시물만 포함
                }.sorted(by: { $0.updateDate > $1.updateDate }) // 최신 업데이트 순으로 정렬
            }
    }
    
    // 기존 코드
    func fetchAllPosts() {
        db.collection("posts")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    self?.filteredPosts = []
                    return
                }

                self?.filteredPosts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Post.self)
                } ?? []
            }
    }
}

extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180.0
    }
}
