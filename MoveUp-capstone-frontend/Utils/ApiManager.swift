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
}

class ApiManager {
    static let shared = ApiManager()
    
    private init() {} // Singleton pattern
    
    func uploadHealthData(payload: HealthDataPayload, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "http://10.228.227.249:5085/api/healthdata") else {
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
