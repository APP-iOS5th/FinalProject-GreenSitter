//
//  Review.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Review: Codable {
    var id: String
    var enabled: Bool
    var createDate: Date
    var updateDate: Date
    var userId: String
    var postId: String
    var rating: Rating
    var reviewText: String?
    var reviewImage: String?
    var selectedTexts: [String]?
}

enum Rating: String, Codable {
    case bad, average, good
}
