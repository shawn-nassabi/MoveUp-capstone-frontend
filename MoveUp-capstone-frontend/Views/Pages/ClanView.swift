//
//  ClanView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

// Member data structure
struct Member: Identifiable {
    let id: String
    let userName: String
    let role: String
}

struct ClanView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var isLoading: Bool = true
    @State private var isInClan: Bool? = nil // nil means the API is still loading
    @State private var clanMemberDetails: ClanMember? = nil // Holds user's clan details if they are in a clan
    
    // Sample data for members
    @State private var members: [Member] = [
        Member(id: "1", userName: "John_Doe", role: "LEADER"),
        Member(id: "2", userName: "Shawn_Nassabi", role: "MEMBER"),
        Member(id: "3", userName: "Jackie_Chan", role: "MEMBER"),
        Member(id: "4", userName: "Emily_Rose", role: "MEMBER")
    ]

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if isInClan == true, let clanMemberDetails = clanMemberDetails {
                clanViewContent(for: clanMemberDetails)
            } else {
                noClanView()
            }
        }
        .onAppear {
            if isInClan == nil { // Avoid refetching if state already determined
                fetchClanDetails()
            }
        }
        
    }
    
    func fetchClanDetails() {
        guard let userId = appState.userId else {
            print("User ID is nil")
            self.isLoading = false
            return
        }

        let url = URL(string: "http://10.228.227.249:5085/api/clan/member/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false // Ensure loading state is reset
            }

            if let error = error {
                print("Error fetching clan details: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                DispatchQueue.main.async {
                    self.isInClan = false
                    print("User is not in a clan")
                }
                return
            }

            if let data = data {
                do {
                    print("Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to print data")")
                    let clanMemberDetails = try JSONDecoder().decode(ClanMember.self, from: data)
                    DispatchQueue.main.async {
                        self.clanMemberDetails = clanMemberDetails
                        self.isInClan = true
                    }
                } catch {
                    print("Error decoding clan details: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func noClanView() -> some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("You are not part of a clan yet.")
                    .font(.headline)
                    .foregroundColor(.gray)

                NavigationLink(destination: CreateClanView()) {
                    Text("Create a Clan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.teal)
                        .cornerRadius(8)
                }

                NavigationLink(destination: SearchClansView()) {
                    Text("Search for Clans")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        
    }
    
    
    func clanViewContent(for details: ClanMember) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("You are a member of")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("The Dubai Warriors")
                            .font(.title)
                            .fontWeight(.heavy)
                    }
                    Spacer()
                    Button(action: {
                        // Navigate to search page
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Challenge Points
                HStack {
                    Text("Challenge Points")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    Spacer()
                    HStack {
                        Image(systemName: "bolt.circle")
                            .foregroundColor(.yellow)
                            .font(.system(size: 24))
                        Text("250")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .padding(8)
                    .background(Color(.white))
                    .cornerRadius(8)
                    .shadow(color: Color.yellow, radius: 2, x: 0, y: 0)
                }
                .padding(.horizontal)
                
                
                // Current Challenge Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("In Progress")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Challenge card
                        ChallengeCardView(
                            goal: "100,000",
                            title: "Steps\nChallenge",
                            progress: 0.75, // 75% progress
                            needed: "25,000"
                        )
                        // View More Challenges button
                        Button(action: {
                            // Navigate to more challenges
                        }) {
                            Text("View More Challenges")
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
                        
                        // Leave button
                        Button(action: {
                            // Leave clan action
                        }) {
                            Text("Leave")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Members Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Members")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    ForEach(members) { member in
                        HStack {
                            // Placeholder for user icon
                            Circle()
                                .fill(Color(.systemGray4))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(member.userName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(member.role.capitalized)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    
                }
                .padding(.top)
            }
            .padding(.vertical)
        }
    }
}


#Preview {
    ClanView()
        .environmentObject(AppState())
}
