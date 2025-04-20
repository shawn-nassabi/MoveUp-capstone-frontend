//
//  ApiManager.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/4/24.
//

import Foundation


struct HealthDataPayload: Codable {
    let userId: String
    let datatypeId: Int
    let dataValue: Double
    let recordedAt: String
    let timeZoneOffset: Int
}

class ApiManager {
    static let shared = ApiManager()
    
    private init() {} // Singleton pattern
    
    func fetchUserPoints(userAddress: String, completion: @escaping (Int?) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/api/blockchain/points/\(userAddress)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let pointsStr = json["points"] as? String,
                   let points = Int(pointsStr) {
                    completion(points)
                    return
                }
            }
            completion(nil)
        }.resume()
    }

    func fetchTokenBalance(userAddress: String, completion: @escaping (Double?) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/api/blockchain/token-balance/\(userAddress)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let balanceStr = json["balance"] as? String,
                   let balance = Double(balanceStr) {
                    completion(balance)
                    return
                }
            }
            completion(nil)
        }.resume()
    }

    func fetchPointsPerTokenRate(completion: @escaping (Int?) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/api/blockchain/points-per-token") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let rateStr = json["pointsPerToken"] as? String,
                   let rate = Int(rateStr) {
                    completion(rate)
                    return
                }
            }
            completion(nil)
        }.resume()
    }
    
    func uploadHealthData(payload: HealthDataPayload, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/api/healthdata") else {
            completion(false, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            completion(false, error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(false, NSError(domain: "Server error", code: -1, userInfo: nil))
                return
            }
            
            completion(true, nil)
        }.resume()
    }
}
