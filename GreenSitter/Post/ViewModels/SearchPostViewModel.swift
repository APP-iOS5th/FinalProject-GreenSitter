//
//  SearchPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/28/24.
//

import FirebaseFirestore
import Combine

class SearchPostViewModel: ObservableObject {
    @Published var filteredPosts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    
    private var allPosts: [Post] = []
    private let db = Firestore.firestore()

    func fetchPostsByCategoryAndLocation(for category: String, userLocation: String?) {
        // Firestore 쿼리 구성
        var query: Query = db.collection("posts").whereField("category", isEqualTo: category)
        
        if let location = userLocation {
            query = query.whereField("location", isEqualTo: location)
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No posts found")
                return
            }
            
            self?.allPosts = documents.compactMap { document -> Post? in
                try? document.data(as: Post.self)
            }
            self?.filteredPosts = self?.allPosts ?? []
        }
    }
    
    func filterPosts(with searchText: String) {
        if searchText.isEmpty {
            filteredPosts = allPosts
        } else {
            let lowercasedSearchText = searchText.lowercased()
            filteredPosts = allPosts.filter { post in
                post.postTitle.lowercased().contains(lowercasedSearchText) ||
                post.postBody.lowercased().contains(lowercasedSearchText) ||
                post.nickname.lowercased().contains(lowercasedSearchText)
            }
        }
    }
}
