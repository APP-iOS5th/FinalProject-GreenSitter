//
//  Report.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/30/24.
//

import Foundation

enum ReportType: String, Codable {
    case post
    case user
}

struct Report: Codable {
    var reporterId: String // 신고한 사용자 ID
    var reportedId: String // 신고된 포스트 또는 사용자 ID
    var reportType: ReportType // 신고 타입 (포스트 또는 사용자)
    var reportDate: Date // 신고 일자
    var reason: String // 신고 이유 (추가 정보)
}
