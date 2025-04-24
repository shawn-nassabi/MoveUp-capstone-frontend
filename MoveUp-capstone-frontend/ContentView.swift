//
//  ContentView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.userId == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .animation(.default, value: appState.userId)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Image(systemName: "house"); Text("Home") }

            BenchmarksView()
                .tabItem { Image(systemName: "flag.checkered"); Text("Benchmarks") }

            ClanView()
                .tabItem { Image(systemName: "person.3"); Text("Clan") }

            ProfileView()
                .tabItem { Image(systemName: "person.crop.circle"); Text("Profile") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
