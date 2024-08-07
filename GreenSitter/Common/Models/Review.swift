//
//  Review.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Review: Codable {
    let id: UUID
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let userId: UUID
    let postId: UUID
    let rating: Rating
    let reviewText: String?
    let reviewImage: String?
}

enum Rating: String, Codable {
    case bad, average, good
}
