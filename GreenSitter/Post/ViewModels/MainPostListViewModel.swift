//
//  MainPostListViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/22/24.
//

import Foundation
import FirebaseFirestore
import Combine

class MainPostListViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var filteredPosts: [Post] = []
    private var lastDocumentSnapshot: DocumentSnapshot? // 마지막 문서를 추적하기 위한 변수
    private let pageSize = 10 // 페이지 당 불러올 문서 수
    @Published var isLoading = false // 로딩 상태를 추적

    // MARK: - Haversine 공식을 사용하여 두 위치 간의 거리 계산 (단위: 미터)
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm: Double = 6371.0

        let dLat = (lat2 - lat1).degreesToRadians
        let dLon = (lon2 - lon1).degreesToRadians

        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1.degreesToRadians) * cos(lat2.degreesToRadians) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusKm * c * 1000 // 결과를 미터로 반환
    }
    
    // MARK: - 카테고리, 위치 정보로 Post 필터링
    func fetchPostsByCategoryAndLocation(for category: String, userLocation: Location?, loadMore: Bool = false) {
        // 이미 로딩 중이면 새로운 요청을 하지 않음
//        guard !isLoading else {
//            print("isLoading: \(isLoading)")
//            return
//        }
        isLoading = true

        guard let postType = PostType(rawValue: category) else {
            filteredPosts = []
            isLoading = false
            return
        }
        
        var query = db.collection("posts")
            .whereField("postType", isEqualTo: postType.rawValue)
            .order(by: "updateDate", descending: true)
            .limit(to: pageSize)
       
        // loadMore 가 true 일 경우, 마지막 스냅샷 이후부터 데이터 가져오기
        if loadMore, let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        query.getDocuments { [weak self] (QuerySnapshot, error) in
            defer { self?.isLoading = false } // 로딩 종료 후 isLoading 상태를 false로 변경

            if let error = error {
                print("error getting documents: \(error)")
                self?.filteredPosts = []
                return
            }
            
            guard let documents = QuerySnapshot?.documents else {
                self?.filteredPosts = []
                return
            }
            
            let posts = documents.compactMap { try? $0.data(as: Post.self) }
            
            // 위치 필터링 시작
            let filtered = posts.filter { post in
                guard let postLocation = post.location else {
                    return false
                }
                
                let distance = self?.calculateDistance(
                    lat1: userLocation?.latitude ?? Location.seoulLocation.latitude,
                    lon1: userLocation?.longitude ?? Location.seoulLocation.longitude,
                    lat2: postLocation.latitude,
                    lon2: postLocation.longitude
                ) ?? Double.greatestFiniteMagnitude
                return distance <= 30000 // 30km 이내의 게시물만 포함
            }
            
            if loadMore {
                let newPosts = filtered.filter { newPost in
                    guard let strongSelf = self else { return false }
                    return !strongSelf.filteredPosts.contains { $0.id == newPost.id }
                }
                self?.filteredPosts.append(contentsOf: newPosts)
            } else {
                self?.filteredPosts = filtered
            }
            
            self?.lastDocumentSnapshot = documents.last // 마지막 문서를 저장
        }
    }
    
    // MARK: - 위치 정보로 Post 필터링
    func fetchPostsWithin3Km(userLocation: Location?) {
        
        db.collection("posts")
            .getDocuments { [weak self] (querySnapshot, error) in
                
                if let error = error {
                    print("Error getting documents: \(error)")
                    self?.filteredPosts = []
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    self?.filteredPosts = []
                    return
                }

                let posts = documents.compactMap { document in
                    try? document.data(as: Post.self)
                }
                
                // 사용자 위치를 기준으로 3km 이내의 게시물 필터링 및 최신 업데이트 순으로 정렬
                self?.filteredPosts = posts.filter { post in

                    // post.location이 nil인 경우 필터링에서 제외
                    guard let postLocation = post.location else {
                        return false
                    }
                    
                    let distance = self?.calculateDistance(
                        lat1: userLocation?.latitude ?? Location.seoulLocation.latitude,    // 위치 정보 파라미터 값 안받으면 기본 값은 서울 시청!
                        lon1: userLocation?.longitude ?? Location.seoulLocation.longitude,
                        lat2: postLocation.latitude,
                        lon2: postLocation.longitude
                    ) ?? Double.greatestFiniteMagnitude

                    return distance <= 30000 // 30km 이내의 게시물만 포함
                }.sorted(by: { $0.updateDate > $1.updateDate }) // 최신 업데이트 순으로 정렬
            }
    }
}
