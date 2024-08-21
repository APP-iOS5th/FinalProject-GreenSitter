//
//  Review.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Review: Codable {
    let id: String
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let userId: String
    let postId: String
    let rating: Rating
    let reviewText: String?
    let reviewImage: String?
    let selectedTexts: [String]?
}

enum Rating: String, Codable {
    case bad, average, good
}
