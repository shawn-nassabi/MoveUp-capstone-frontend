//
//  ProfileView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var isConverting = false
    @State private var showMessage = false
    @State private var conversionMessage = ""
    @State private var isSuccess = true
    @State private var showingHistory = false
    
    // Placeholder user details (you can replace these with dynamic data later)
    let username = "shawn_nassabi"
    let age = 22
    let location = "Dubai, UAE"
    let gender = "Male"
    
    // Local helper method that calls the AppState conversion method
    private func convertPointsToTokens() {
        isConverting = true
        showMessage = false
        conversionMessage = ""
        
        appState.convertPointsToTokens { success, message in
            DispatchQueue.main.async {
                isConverting = false
                isSuccess = success
                conversionMessage = message
                showMessage = true
                
                if success {
                    appState.fetchBlockchainData()
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Picture
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3)) // Background for the placeholder
                            .frame(width: 120, height: 120)

                        Image(systemName: "person.fill") // Placeholder icon
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40) // Adds spacing from the top

                    // User Details
                    VStack(spacing: 10) {
                        // Username
                        Text(appState.userData?["username"] as? String ?? username)
                            .font(.title)
                            .fontWeight(.bold)

                        // Age
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Age: \(appState.userData?["age"] as? Int ?? age)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        // Location
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.gray)
                            Text("Location: \(appState.userData?["location"] as? String ?? location)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        // Gender
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.gray)
                            Text("Gender: \(appState.userData?["gender"] as? String ?? gender)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    // Blockchain info section
                    Section(header: Text("Blockchain Wallet Info").font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Points:")
                                Spacer()
                                Text("\(appState.userPoints ?? 0)")
                            }

                            HStack {
                                Text("Tokens:")
                                Spacer()
                                Text(String(format: "%.4f HDT", appState.userTokenBalance ?? 0.0))
                            }

                            HStack {
                                Text("Points per Token conversion rate:")
                                Spacer()
                                Text("\(appState.pointsPerToken ?? 0)")
                            }

                            // Progress / Button & Message
                            if isConverting {
                                HStack {
                                    Spacer()
                                    ProgressView("Converting points...")
                                    Spacer()
                                }
                                .padding()
                            } else {
                                Button(action: {
                                    convertPointsToTokens()
                                }) {
                                    Text("Convert Points to Tokens")
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background((appState.userPoints ?? 0) >= (appState.pointsPerToken ?? Int.max) ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled((appState.userPoints ?? 0) < (appState.pointsPerToken ?? Int.max))
                            }
                            if showMessage {
                                Text(conversionMessage)
                                    .foregroundColor(isSuccess ? .green : .red)
                                    .font(.subheadline)
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(nil)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        Button {
                          showingHistory = true
                        } label: {
                          Label("History", systemImage: "clock.arrow.circlepath")
                        }
                        .sheet(isPresented: $showingHistory) {
                          NavigationView {
                            RewardHistoryView()
                          }
                        }
                    }
                    
                    Text("On this page you can view your profile details, edit your goals, and see your blockchain wallet info. Each day at 3:00 UTC your contributions are synced on-chain and you earn points; if you have enough points, you can convert them into HDT tokens.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .fixedSize(horizontal: false, vertical: true)

                    // Log Out button
                    Button(action: {
                        appState.clearSession()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                    Spacer() // Pushes everything to the top
                }
                .padding()
                .padding(.horizontal, 10)
            }
            .refreshable {
                appState.fetchBlockchainData()
            }
            .onAppear {
                appState.fetchBlockchainData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditGoalsView()) {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(AppState())

}
