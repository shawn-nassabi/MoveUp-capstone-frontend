//
//  AppState.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/4/24.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var userId: String? = "6dfa161b-9a4f-4857-b82a-2125e99e8331"
    @Published var userData: [String: Any]? = nil
    @Published var healthDataTypes: [[String: Any]]? = nil
    
    // Fetch user data from the backend API
    func fetchUserData() {
        guard let url = URL(string: "http://10.228.227.249:5085/api/user/6dfa161b-9a4f-4857-b82a-2125e99e8331") else {
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
        guard let url = URL(string: "http://10.228.227.249:5085/api/datatype") else {
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

            // Fetch and upload steps
            healthKit.fetchStepCount { steps, error in
                guard let steps = steps else { return }
                let payload = HealthDataPayload(userId: userId, datatypeId: 1, dataValue: steps, recordedAt: currentTime)
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
                let payload = HealthDataPayload(userId: userId, datatypeId: 2, dataValue: calories, recordedAt: currentTime)
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
                let payload = HealthDataPayload(userId: userId, datatypeId: 3, dataValue: heartRate, recordedAt: currentTime)
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
                let payload = HealthDataPayload(userId: userId, datatypeId: 4, dataValue: sleepHours, recordedAt: currentTime)
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
                let payload = HealthDataPayload(userId: userId, datatypeId: 5, dataValue: exerciseMinutes, recordedAt: currentTime)
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
                let payload = HealthDataPayload(userId: userId, datatypeId: 6, dataValue: distance, recordedAt: currentTime)
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
