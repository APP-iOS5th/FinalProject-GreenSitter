//
//  LevelPoint.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

enum Level: String, Codable,CaseIterable {
    case rottenSeeds = "썩은 씨앗"
    case seeds = "씨앗"
    case sprout = "새싹"
    case seedling = "유묘"
    case flower = "꽃"
    case fruit = "열매"
    
    //다음 레벨을 반환
    func nextLevel() -> Level {
        let allLevels = Level.allCases
        if let currentIndex = allLevels.firstIndex(of: self), currentIndex < allLevels.count
            - 1 {
            return allLevels[currentIndex + 1]
        }
        return self //최종 레벨이면 더이상 올리지 않음
    }
    
    // 이전 레벨을 반환
    func previousLevel() -> Level {
        let allLevels = Level.allCases
        if let currentIndex = allLevels.firstIndex(of: self), currentIndex > 0 {
            return allLevels[currentIndex - 1]
        }
        return self // 최하위 레벨이면 더 이상 내리지 않음
    }
    
}
