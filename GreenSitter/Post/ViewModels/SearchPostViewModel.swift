//
//  SearchPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/28/24.
//

import Foundation
import Combine

class SearchPostViewModel {
    private let posts: [Post]
    
    @Published var filteredPosts: [Post] = [] {
        didSet {
            onPostsChanged?(filteredPosts.isEmpty)
        }
    }
    
    var onPostsChanged: ((Bool) -> Void)?
    
    init(posts: [Post]) {
        self.posts = posts
        onPostsChanged?(filteredPosts.isEmpty)
    }
    
    func filterPosts(with searchText: String) {
        if searchText.isEmpty {
            filteredPosts = [] // 검색어가 없을 경우 빈 배열
        } else {
            filteredPosts = posts.filter {
                $0.postTitle.contains(searchText) ||
                $0.postBody.contains(searchText)
            }
        }
    }
}

