//
//  KakaoAPIService.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/13/24.
//

import Foundation

class KakaoAPIService {
    
    let restAPIKey = Bundle.main.kakaoRestAPIKey
    
    func fetchRegionInfo(for location: Location, completion: @escaping (Result<Location, Error>) -> Void) {
        let latitude = location.latitude
        let longitude = location.longitude
        
        guard let url = URL(string: "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=\(longitude)&y=\(latitude)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("KakaoAK \(restAPIKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                var updatedLocation = location
                let response = try JSONDecoder().decode(KakaoAPIResponse.self, from: data)
                if let firstDocument = response.documents.first {
                    updatedLocation.address = firstDocument.address_name
                }
                completion(.success(updatedLocation))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct KakaoAPIResponse: Codable {
    let meta: Meta
    let documents: [Document]
}

struct Meta: Codable {
    let total_count: Int
}

struct Document: Codable {
    let region_type: String // H(행정동) 또는 B(법정동)
    let address_name: String    // 전체 지역 명칭
    let region_1depth_name: String  // 시도 단위
    let region_2depth_name: String  // 구 단위
    let region_3depth_name: String  // 동 단위
    let region_4depth_name: String? // region_type이 법정동이며, 리 영역인 경우만 존재
    let code: String    // region 코드
    let x: Double   // longitude
    let y: Double   // latutude
}

//// Usage example
//let location = Location(enabled: true, createDate: Date(), updateDate: Date())
//let kakaoAPIService = KakaoAPIService()
//
//kakaoAPIService.fetchRegionInfo(for: location) { result in
//    switch result {
//    case .success(let documents):
//        for document in documents {
//            print("Address: \(document.address_name)")
//        }
//    case .failure(let error):
//        print("Error fetching region info: \(error)")
//    }
//}
