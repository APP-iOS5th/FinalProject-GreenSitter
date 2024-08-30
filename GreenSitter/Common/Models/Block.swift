//
//  Block.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/30/24.
//

import Foundation

enum BlockType: String, Codable {
    case post
    case user
}

struct Block: Codable {
    var blockerId: String // 차단한 사용자 ID
    var blockedId: String // 차단된 포스트 또는 사용자 ID
    var blockType: BlockType // 차단 타입 (포스트 또는 사용자)
    var blockDate: Date // 차단 일자
}
