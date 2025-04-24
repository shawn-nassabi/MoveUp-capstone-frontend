//
//  MoveUp_capstone_frontendApp.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

@main
struct MoveUp_capstone_frontendApp: App {
    @StateObject private var appState = AppState() // Single instance of global state
    
    init() {
//        appState.loadSession()
        HealthKitManager.shared.requestAuthorization { success, error in
            if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            } else if success {
                print("HealthKit authorization succeeded!")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState) // Inject AppState
                .onAppear {
                    appState.fetchUserData()
                    appState.fetchHealthDataTypes()
                    appState.uploadHealthDataOnStartup()
                }
        }
        
    }
}
