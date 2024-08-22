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

    func fetchPosts(for category: String) {
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
}
