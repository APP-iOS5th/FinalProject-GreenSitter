//
//  KakaoAPIService.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/13/24.
//

import Foundation

class KakaoAPIService {
    
    static let shared = KakaoAPIService()
    
    private init() {}
    
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
        
        // 네트워크 요청 준비
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
        // 네트워크 요청 시작
        task.resume()
    }
    
    
    // MARK: - 내 위치 주변의 장소 검색
    func searchPlacesNearby(query: String, location: Location, page: Int = 1, size: Int = 15, sort: String = "accuracy", completion: @escaping (Result<([Location], Bool), Error>) -> Void) {
            let latitude = location.latitude
            let longitude = location.longitude
            
            var urlComponents = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
            urlComponents?.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "x", value: "\(longitude)"),
                URLQueryItem(name: "y", value: "\(latitude)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)"),
                URLQueryItem(name: "sort", value: sort)
            ]
            
            guard let url = urlComponents?.url else {
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
                    let response = try JSONDecoder().decode(KakaoPlaceSearchResponse.self, from: data)
                    let locations = response.documents.map { document in
                        Location(
                            enabled: true,
                            createDate: Date(),
                            updateDate: Date(),
                            latitude: Double(document.y) ?? 0.0,
                            longitude: Double(document.x) ?? 0.0,
                            placeName: document.place_name,
                            address: document.road_address_name ?? ""
                        )
                    }
                    completion(.success((locations, response.meta.is_end)))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    
}

// MARK: - 좌표로 행정구역정보 받기 위한 API 모델들
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

// MARK: - 장소 검색 API 응답 모델들
struct KakaoPlaceSearchResponse: Codable {
    let meta: PlaceSearchMeta
    let documents: [PlaceDocument]
}

struct PlaceSearchMeta: Codable {
    let total_count: Int          // 검색된 전체 문서 수
    let pageable_count: Int       // 노출 가능한 문서 수 (최대 45)
    let is_end: Bool              // 현재 페이지가 마지막 페이지인지 여부
}

struct PlaceDocument: Codable {
    let place_name: String        // 장소명
    let road_address_name: String? // 도로명 주소
    let x: String                 // 경도 (longitude)
    let y: String                 // 위도 (latitude)
}
