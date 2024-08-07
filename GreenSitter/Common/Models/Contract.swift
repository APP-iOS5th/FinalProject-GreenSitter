//
//  Contract.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Contract: Codable {
    let contractId: UUID
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let ownerId: UUID
    let sitterId: UUID
    let ownerNickname: String
    let sitterNickname: String
    let ownerProfileImage: String
    let sitterProfileImage: String
    let plantName: String?
    let plantType: String?
    let plantImage: String?
    let plantStatus: String?
    let startCareDate: Date
    let endCareDate: Date
    let carePrice: Int
    let contractContent: String?
    let ownerSignImage: String?
    let sitterSignImage: String?
}
