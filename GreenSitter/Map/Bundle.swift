//
//  Bundle.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

extension Bundle {
    var kakaoAPIKey: String {
        guard let file = self.path(forResource: "APIKey", ofType: "plist") else { fatalError("APIKey.plist not found.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("파일 형식 에러") }
        guard let key = resource["KakaoAPIKey"] as? String else { fatalError("APIKey에 KakaoAPIKey을 설정해주세요.")}
        return key
    }
}

