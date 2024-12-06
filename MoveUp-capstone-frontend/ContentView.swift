//
//  ContentView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View { // 'some View' tells SwiftUI that the body must return one or more SwiftUI views
        TabView {
            DashboardView() // Tab 1: Main Dashboard
                .tabItem {
                    Image(systemName: "house") // Home icon
                    Text("Home")
                }
                    
            BenchmarksView() // Tab 2: Achievements/Goals
                .tabItem {
                    Image(systemName: "flag.checkered") // Flag icon
                    Text("Benchmarks")
                }
                    
            ClanView() // Tab 3: Friends/Social
                .tabItem {
                    Image(systemName: "person.3") // Friends icon
                    Text("Clan")
                }
                    
            ProfileView() // Tab 4: Profile/Settings
                .tabItem {
                    Image(systemName: "person.crop.circle") // Profile icon
                    Text("Profile")
                }
        }
        
        
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
