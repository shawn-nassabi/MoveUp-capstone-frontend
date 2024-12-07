//
//  ClanChallengesView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//


import SwiftUI

struct ClanChallengesView: View {
    let clanId: String
    
    @EnvironmentObject var appState: AppState // State management
    @State private var challenges: [Challenge] = [] // Holds the challenges
    @State private var isLoading: Bool = true       // Indicates data fetching
    @State private var errorMessage: String? = nil // For error handling

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Challenges...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if challenges.isEmpty {
                Text("No challenges available.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        if let clanMemberRole = appState.clanMemberDetails?.role {
                            if clanMemberRole == "Leader" {
                                // TODO: Button to start a new challenge
                                NavigationLink(destination: CreateChallengeView(clanId: clanId)) {
                                    Text("Create a New Challenge")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.teal, Color.blue]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(8)
                                }
                                .padding(.vertical)
                            }
                        }
                        
                        ForEach(challenges) { challenge in
                            ChallengeCardView(
                                challengeDetails: challenge,
                                goal: "\(challenge.goal)",
                                title: challenge.challengeName,
                                progress: Double(challenge.totalProgress) / Double(challenge.goal),
                                needed: "\(challenge.goal - challenge.totalProgress)"
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.bottom) // Extend the view beyond the safe area
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand VStack to fill the screen
        .navigationTitle("Clan Challenges")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchChallenges()
        }
    }

    func fetchChallenges() {
        guard let url = URL(string: "http://10.228.227.249:5085/api/clan/\(clanId)/challenges") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error fetching challenges: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                do {
                    let fetchedChallenges = try JSONDecoder().decode([Challenge].self, from: data)
                    DispatchQueue.main.async {
                        challenges = fetchedChallenges
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to decode challenges: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    ClanChallengesView(clanId: "08613e25-1b60-4171-bb85-aab513aebc37")
        .environmentObject(AppState())
}
