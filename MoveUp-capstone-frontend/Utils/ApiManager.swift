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

// Used for logging in
struct LoginPayload: Codable {
    let username: String
    let password: String
}

class ApiManager {
    static let shared = ApiManager()
    
    private init() {} // Singleton pattern
    
    func login(username: String, password: String, completion: @escaping (Bool, String?, [String: Any]?) -> Void) {
            guard let url = URL(string: "\(API.baseURL)/api/login") else {
                completion(false, "Invalid URL", nil)
                return
            }

            let payload = LoginPayload(username: username, password: password)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(payload)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, error.localizedDescription, nil)
                    return
                }

                guard let data = data else {
                    completion(false, "No data returned", nil)
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let userId = json["userId"] as? String {
                        completion(true, "Login successful", json)
                    } else {
                        completion(false, json["message"] as? String ?? "Login failed", nil)
                    }
                } else {
                    completion(false, "Failed to parse response", nil)
                }
            }.resume()
        }
    
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
    
  func fetchPointsHistory(userAddress: String,
                          completion: @escaping ([PointsRewardHistoryDto]?, Error?) -> Void) {
    guard let url = URL(string: "\(API.baseURL)/api/blockchain/history/points/\(userAddress)") else {
      completion(nil, URLError(.badURL))
      return
    }

    var req = URLRequest(url: url)
    req.httpMethod = "GET"

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    URLSession.shared.dataTask(with: req) { data, resp, err in
      if let err = err { return completion(nil, err) }
      guard let data = data else { return completion(nil, URLError(.badServerResponse)) }
      do {
        let list = try decoder.decode([PointsRewardHistoryDto].self, from: data)
        completion(list, nil)
      } catch {
        completion(nil, error)
      }
    }.resume()
  }

  func fetchTokenHistory(userAddress: String,
                         completion: @escaping ([TokenRewardHistoryDto]?, Error?) -> Void) {
    guard let url = URL(string: "\(API.baseURL)/api/blockchain/history/tokens/\(userAddress)") else {
      completion(nil, URLError(.badURL))
      return
    }

    var req = URLRequest(url: url)
    req.httpMethod = "GET"

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    URLSession.shared.dataTask(with: req) { data, _, err in
      if let err = err { return completion(nil, err) }
      guard let data = data else { return completion(nil, URLError(.badServerResponse)) }
      do {
        let list = try decoder.decode([TokenRewardHistoryDto].self, from: data)
        completion(list, nil)
      } catch {
        completion(nil, error)
      }
    }.resume()
  }
    
}
