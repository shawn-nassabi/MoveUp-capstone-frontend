//
//  AppState.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/4/24.
//
// 0229c018-c8e4-4321-86e0-1c1f1ee3b4bc - user38
// 6dfa161b-9a4f-4857-b82a-2125e99e8331 - shawn

import SwiftUI
import Combine

class AppState: ObservableObject {
//    @Published var userId: String? = "0a2b3ac1-2a55-4151-9fd1-92d654e7940d"
    // Persisted keys in UserDefaults:
    @AppStorage("userId", store: .standard) var userId: String?
    @AppStorage("walletAddress", store: .standard) var walletAddress: String?
    
    @Published var userData: [String: Any]? = nil
    @Published var healthDataTypes: [[String: Any]]? = nil
    
    @Published var isLoadingClanDetails: Bool = false
    @Published var clanMemberDetails: ClanMember?
    @Published var clanDetails: Clan?
    
    // The following are variables for blockchain related data
    @Published var userPoints: Int? = nil
    @Published var userTokenBalance: Double? = nil
    @Published var pointsPerToken: Int? = nil
    
    @Published var pointsHistory: [PointsRewardHistoryDto] = []
    @Published var tokenHistory:  [TokenRewardHistoryDto]  = []
    
    @Published var healthGoals: [String: Int] = [
        "steps": 10000,
        "calories": 650,
        "resting_heartrate": 60,
        "sleep": 8,
        "exercise_minutes": 30,
        "distance": 5
    ]
    
    init() {
            // If we already have a userId in AppStorage,
            // immediately fetch everything we need:
            if let uid = userId, let wallet = walletAddress {
                // load profile, blockchain info, etc.
                fetchUserData()
                fetchBlockchainData()
            }
        }
    
    // Persist and store login related/session data ----------------------------------
    func saveSession(userId: String, wallet: String) {
        // Just assign—@AppStorage writes automatically
        self.userId        = userId
        self.walletAddress = wallet
        // And pull in the data you’ll want on first launch:
        fetchUserData()
        fetchBlockchainData()
        refreshClanDetails()
    }

    func clearSession() {
        // Wipe out saved defaults and in-memory:
        userId        = nil
        walletAddress = nil
        userData      = nil
        clanMemberDetails = nil     // ← clear leftover clan cache
        clanDetails        = nil
        pointsHistory = []
        tokenHistory  = []
        // clear any other state as needed…
    }

    func loadSession() {
        if let uid = UserDefaults.standard.string(forKey: "userId"),
           let wal = UserDefaults.standard.string(forKey: "walletAddress") {
            self.userId = uid
            self.walletAddress = wal
            fetchUserData()
            fetchBlockchainData()
        }
    }

//    func clearSession() {
//        UserDefaults.standard.removeObject(forKey: "userId")
//        UserDefaults.standard.removeObject(forKey: "walletAddress")
//        self.userId = nil
//        self.walletAddress = nil
//    }
    
    // ----------------------------------------------------------------------------------
    
    func fetchBlockchainData() {
        guard let userId = userId else { return }

        fetchUserPoints(userAddress: userId)
        fetchTokenBalance(userAddress: userId)
        fetchPointsPerTokenRate()
    }
    
    func fetchUserPoints(userAddress: String) {
        ApiManager.shared.fetchUserPoints(userAddress: userAddress) { points in
            DispatchQueue.main.async {
                self.userPoints = points
                print("Points: \(String(describing: self.userPoints))")
            }
        }
    }

    func fetchTokenBalance(userAddress: String) {
        ApiManager.shared.fetchTokenBalance(userAddress: userAddress) { balance in
            DispatchQueue.main.async {
                self.userTokenBalance = balance
                print("Token Balance: \(String(describing: self.userTokenBalance))")
            }
        }
    }

    func fetchPointsPerTokenRate() {
        ApiManager.shared.fetchPointsPerTokenRate { rate in
            DispatchQueue.main.async {
                self.pointsPerToken = rate
                print("Points per Token: \(String(describing: self.pointsPerToken))")
            }
        }
    }
    
    func fetchPointsHistory() {
        guard let userId = userId else { return }
        ApiManager.shared.fetchPointsHistory(userAddress: userId) { list, err in
          DispatchQueue.main.async {
            self.pointsHistory = list ?? []
          }
        }
      }

      func fetchTokenHistory() {
        guard let userId = userId else { return }
        ApiManager.shared.fetchTokenHistory(userAddress: userId) { list, err in
          DispatchQueue.main.async {
            self.tokenHistory = list ?? []
          }
        }
      }
    
    func convertPointsToTokens(completion: @escaping (Bool, String) -> Void) {
        guard let userId = userId else {
            completion(false, "User ID not available.")
            return
        }

        guard let url = URL(string: "\(API.baseURL)/api/blockchain/convert-points-to-tokens") else {
            completion(false, "Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["userId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "No response from server.")
                return
            }

            if httpResponse.statusCode == 200 {
                completion(true, "✅ Points converted to tokens successfully!")
            } else {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(false, message)
                } else {
                    completion(false, "❌ Conversion failed with status code \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func refreshClanDetails() {
        print("Fetching clan details")
        
        isLoadingClanDetails = true

        guard let userId = userId else {
            print("User ID is nil. Failed to refresh clan member details")
            isLoadingClanDetails = false
            return
        }

        guard let url = URL(string: "\(API.baseURL)/api/clan/member/\(userId)") else {
            print("Invalid URL")
            isLoadingClanDetails = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            if let error = error {
                print("Error fetching clan details: \(error.localizedDescription)")
                self.isLoadingClanDetails = false
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                self.isLoadingClanDetails = false
                return
            }

            if httpResponse.statusCode == 404 {
                DispatchQueue.main.async {
                    self.clanMemberDetails = nil
                    self.clanDetails = nil
                    print("User is not in a clan")
                    self.clanMemberDetails = nil
                    self.isLoadingClanDetails = false
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected status code: \(httpResponse.statusCode)")
                self.isLoadingClanDetails = false
                return
            }


            if let data = data {
                do {
                    let clanMemberDetails = try JSONDecoder().decode(ClanMember.self, from: data)
                    DispatchQueue.main.async {
                        self.clanMemberDetails = clanMemberDetails
                        self.fetchClanDetails(for: clanMemberDetails.clanId)
                    }
                } catch {
                    print("Error decoding clan member details: \(error.localizedDescription)")
                    self.isLoadingClanDetails = false
                }
            }
        }.resume()
    }
    
    func fetchClanDetails(for clanId: String) {
        print("Fetching details for clan ID: \(clanId)")
        DispatchQueue.main.async {
            self.isLoadingClanDetails = false
        }

        guard let url = URL(string: "\(API.baseURL)/api/clan/\(clanId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching clan details: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected status code: \(httpResponse.statusCode)")
                return
            }

            guard let data = data, !data.isEmpty else {
                print("No data received from server")
                return
            }

            do {
                let clanDetails = try JSONDecoder().decode(Clan.self, from: data)
                DispatchQueue.main.async {
                    self.clanDetails = clanDetails
                    print("Fetched clan details: \(clanDetails)")
                }
            } catch {
                print("Error decoding clan details: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Fetch user data from the backend API
    func fetchUserData() {
        guard let url = URL(string: "\(API.baseURL)/api/user/\(userId ?? "")") else {
            print("Invalid URL")
            return
        }

        // Perform the API request
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from API when retrieving user data")
                return
            }

            // Parse JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.userData = json // Update the AppState with the fetched data
                        print("User data fetched successfully")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    // Fetch health data types from backend
    func fetchHealthDataTypes() {
        print("Inside fetching health data types")
        guard let url = URL(string: "\(API.baseURL)/api/datatype") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching health data types: \(error.localizedDescription)")
                return
            }
            
            // Ensure the response is an HTTP response and check the status code
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response format")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Error: HTTP Status Code \(httpResponse.statusCode)")
                return
            }

            guard let data = data else {
                print("No data received from API when retrieving health data types")
                return
            }
            
            print("Fetching health data types")
            // Parse JSON response
            do {
                print("Doing json deserialization")
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.healthDataTypes = json // Update the AppState with the fetched data
                        print("Health data types fetched successfully")
//                        print(self.healthDataTypes ?? "No health data types available")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    // Uploading health data to backend upon startup
    func uploadHealthDataOnStartup() {
            guard let userId = userId else {
                print("User ID is nil, cannot upload health data.")
                return
            }

            let healthKit = HealthKitManager.shared
            let currentTime = ISO8601DateFormatter().string(from: Date())
            let timeZoneOffset = TimeZone.current.secondsFromGMT() / 60 // Offset in minutes
            print("Adding health data for time: \(currentTime)")
            // Fetch and upload steps
            healthKit.fetchStepCount { steps, error in
                guard let steps = steps else { return }
                let payload = HealthDataPayload(userId: userId, datatypeId: 1, dataValue: steps, recordedAt: currentTime, timeZoneOffset: timeZoneOffset)
                ApiManager.shared.uploadHealthData(payload: payload) { success, error in
                    if success {
                        print("Steps uploaded successfully.")
                    } else {
                        print("Failed to upload steps: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }

            // Fetch and upload active calories
            healthKit.fetchActiveCalories { calories, error in
                guard let calories = calories else {
                    print("calories is nil, cannot upload calories.")
                    return
                }
                let payload = HealthDataPayload(userId: userId, datatypeId: 2, dataValue: calories, recordedAt: currentTime, timeZoneOffset: timeZoneOffset)
                ApiManager.shared.uploadHealthData(payload: payload) { success, error in
                    if success {
                        print("Calories uploaded successfully.")
                    } else {
                        print("Failed to upload calories: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        
            // Fetch and upload resting heart rate
            healthKit.fetchRestingHeartRate { heartRate, error in
                guard let heartRate = heartRate else { return }
                let payload = HealthDataPayload(userId: userId, datatypeId: 3, dataValue: heartRate, recordedAt: currentTime, timeZoneOffset: timeZoneOffset)
                ApiManager.shared.uploadHealthData(payload: payload) { success, error in
                    if success {
                        print("Resting heart rate uploaded successfully.")
                    } else {
                        print("Failed to upload resting heart rate: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }

            // Fetch and upload sleep
            healthKit.fetchSleepData { sleepHours, error in
                guard let sleepHours = sleepHours else { return }
                let payload = HealthDataPayload(userId: userId, datatypeId: 4, dataValue: sleepHours, recordedAt: currentTime, timeZoneOffset: timeZoneOffset)
                ApiManager.shared.uploadHealthData(payload: payload) { success, error in
                    if success {
                        print("Sleep data uploaded successfully.")
                    } else {
                        print("Failed to upload sleep data: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }

            

            // Fetch and upload exercise minutes
            healthKit.fetchExerciseMinutes { exerciseMinutes, error in
                guard let exerciseMinutes = exerciseMinutes else {
                    print("No exercise minutes found. Cannot upload.")
                    return
                }
                let payload = HealthDataPayload(userId: userId, datatypeId: 5, dataValue: exerciseMinutes, recordedAt: currentTime, timeZoneOffset: timeZoneOffset)
                ApiManager.shared.uploadHealthData(payload: payload) { success, error in
                    if success {
                        print("Exercise minutes uploaded successfully.")
                    } else {
                        print("Failed to upload exercise minutes: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }

            // Fetch and upload distance
            healthKit.fetchTotalDistance { distance, error in
                guard let distance = distance else { return }
                let payload = HealthDataPayload(userId: userId, datatypeId: 6, dataValue: distance, recordedAt: currentTime, timeZoneOffset: timeZoneOffset)
                ApiManager.shared.uploadHealthData(payload: payload) { success, error in
                    if success {
                        print("Distance uploaded successfully.")
                    } else {
                        print("Failed to upload distance: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    
    
    
}
