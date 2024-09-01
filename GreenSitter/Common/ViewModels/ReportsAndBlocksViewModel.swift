//
//  ReportsAndBlocksViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ReportsAndBlocksViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    // 저장된 신고 및 차단 데이터
    @Published var reports: [Report] = []
    @Published var blocks: [Block] = []
    
    // 현재 로그인된 사용자 ID
    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: - 신고 데이터 저장
    func reportItem(reportedId: String, reportType: ReportType, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let reporterId = currentUserId else {
            completion(.failure(NSError(domain: "ReportsAndBlocksViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let report = Report(
            reporterId: reporterId,
            reportedId: reportedId,
            reportType: reportType,
            reportDate: Date(),
            reason: reason
        )
        
        do {
            _ = try db.collection("reports").addDocument(from: report)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - 차단 데이터 저장
    func blockItem(blockedId: String, blockType: BlockType, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let blockerId = currentUserId else {
            completion(.failure(NSError(domain: "ReportsAndBlocksViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let block = Block(
            blockerId: blockerId,
            blockedId: blockedId,
            blockType: blockType,
            blockDate: Date()
        )
        
        do {
            _ = try db.collection("blocks").addDocument(from: block)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - 신고 데이터 조회
    func fetchReports(completion: @escaping (Result<[Report], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "ReportsAndBlocksViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("reports").whereField("reporterId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let reports = snapshot?.documents.compactMap { document -> Report? in
                    try? document.data(as: Report.self)
                } ?? []
                self.reports = reports
                completion(.success(reports))
            }
        }
    }

    // MARK: - 차단 데이터 조회
    func fetchBlocks(completion: @escaping (Result<[Block], Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(NSError(domain: "ReportsAndBlocksViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("blocks").whereField("blockerId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let blocks = snapshot?.documents.compactMap { document -> Block? in
                    try? document.data(as: Block.self)
                } ?? []
                self.blocks = blocks
                completion(.success(blocks))
            }
        }
    }
}

