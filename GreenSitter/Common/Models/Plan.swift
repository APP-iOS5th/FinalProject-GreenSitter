//
//  Plan.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

struct Plan: Codable {
    let planId: UUID
    let enabled: Bool
    let createDate: Date
    let updateDate: Date
    let planDate: Date
    let planPlace: Location
    let contract: Contract
    let ownerNotification: Bool
    let sitterNotification: Bool
    let isAccepted: Bool
}
