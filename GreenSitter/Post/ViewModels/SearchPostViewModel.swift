//
//  SearchPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/28/24.
//

import Foundation
import Combine

class SearchPostViewModel: ObservableObject {
    @Published var filteredPosts: [Post] = []
    
    private var allPosts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(posts: [Post]) {
        self.allPosts = posts
    }
    
    func filterPosts(with searchText: String) {
        if searchText.isEmpty {
            filteredPosts = allPosts
        } else {
            filteredPosts = allPosts.filter { post in
                post.postTitle.lowercased().contains(searchText.lowercased()) ||
                post.postBody.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
