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
    let planPlace: Location? // 테스트를 위한 옵셔널 처리
    let contract: Contract? // 테스트를 위한 옵셔널 처리
    let ownerNotification: Bool
    let sitterNotification: Bool
    let isAccepted: Bool
}
