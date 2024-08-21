//
//  BundleExtension.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import Foundation

extension Bundle {
    
    var kakaoNativeAppKey: String {
        guard let file = self.path(forResource: "APPKey", ofType: "plist") else { fatalError("APPKey.plist not found.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("Invalid format for APPKey.plist") }
        guard let key = resource["KakaoNativeAppKey"] as? String else { fatalError("APPKey.plist must contain a value for 'KakaoNativeAppKey'.") }
        return key
    }
    
    var kakaoRestAPIKey: String {
        guard let file = self.path(forResource: "APPKey", ofType: "plist") else { fatalError("APPKey.plist not found.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("Invalid format for APPKey.plist") }
        guard let key = resource["KakaoRestAPIKey"] as? String else { fatalError("APPKey.plist must contain a value for 'KakaoRestAPIKey'.") }
        return key
    }
}

