//
//  Bundle.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

extension Bundle {
    var kakaoNativeAppKey: String {
        guard let file = self.path(forResource: "APIKey", ofType: "plist") else { fatalError("APIKey.plist not found.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("Invalid format for APIKey.plist") }
        guard let key = resource["KakaoAPIKey"] as? String else { fatalError("APIKey.plist must contain a value for 'KakaoAPIKey'.") }
        return key
    }
}

