//
//  ClanView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

class ClanInviteSheetManager: ObservableObject {
    @Published var showSheet: Bool = false // Controls the sheet visibility
    @Published var joinRequests: [JoinRequest] = [] // Stores the join requests
    @Published var isLoading: Bool = false // Tracks loading state for join requests

    func fetchJoinRequests(for clanId: String) {
        guard let url = URL(string: "http://10.228.227.249:5085/api/clan/\(clanId)/invites") else {
            print("Invalid URL")
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("Error fetching join requests: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let requests = try JSONDecoder().decode([JoinRequest].self, from: data)
                    DispatchQueue.main.async {
                        self.joinRequests = requests
                        self.showSheet = true // Show the sheet
                    }
                } catch {
                    print("Error decoding join requests: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func acceptRequest(requestId: String) {
        guard let url = URL(string: "http://10.228.227.249:5085/api/clan/invite/accept/\(requestId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error accepting request: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Remove the request from the list
                    self.joinRequests.removeAll { $0.id == requestId }
                } else {
                    print("Failed to accept request. Unexpected response.")
                }
            }
        }.resume()
    }

    func declineRequest(requestId: String) {
        guard let url = URL(string: "http://10.228.227.249:5085/api/clan/invite/decline/\(requestId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error declining request: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Remove the request from the list
                    self.joinRequests.removeAll { $0.id == requestId }
                } else {
                    print("Failed to decline request. Unexpected response.")
                }
            }
        }.resume()
    }
}

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
    @State private var hasLoadedOnce: Bool = false // Add this to prevent repeated calls
    
    @State private var showLeaveAlert: Bool = false // State for showing the confirmation alert
    
    @State private var navigateToChallenges: Bool = false
    
//    @State private var showJoinRequestsSheet: Bool = false // Controls the sheet visibility
//    @State private var joinRequests: [JoinRequest] = [] // Stores the join requests
//    @State private var isLoadingJoinRequests: Bool = false // Tracks loading state for join requests
    
    @StateObject private var sheetManager = ClanInviteSheetManager() // Manage sheet state
    
    // Sample data for members
    @State private var members: [Member] = [
        Member(id: "1", userName: "John_Doe", role: "LEADER"),
        Member(id: "2", userName: "Shawn_Nassabi", role: "MEMBER"),
        Member(id: "3", userName: "Jackie_Chan", role: "MEMBER"),
        Member(id: "4", userName: "Emily_Rose", role: "MEMBER")
    ]
    
    var body: some View {
        Group {
            if appState.isLoadingClanDetails {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let clanMemberDetails = appState.clanMemberDetails {
                // User is in a clan
                clanViewContent(for: clanMemberDetails)
            } else {
                // User is not in a clan
                noClanView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full-screen layout
        .background(Color(.systemBackground)) // Optional background color
        .edgesIgnoringSafeArea(.bottom) // Adjust for safe area if needed
        .onAppear {
            if !hasLoadedOnce {
                appState.refreshClanDetails()
                hasLoadedOnce = true
            }
        }
        .sheet(isPresented: $sheetManager.showSheet) {
                VStack {
                    if sheetManager.isLoading {
                        ProgressView("Loading join requests...")
                            .padding(.top, 20)
                    } else if sheetManager.joinRequests.isEmpty {
                        Text("No join requests received.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                            .padding(.top, 20)
                    } else {
                        Text("Clan Join Requests")
                            .font(.system(size: 24, weight: .heavy))
                            .padding(.top)
                        ScrollView {
                            VStack(spacing: 16) { // Adds spacing between requests
                                ForEach(sheetManager.joinRequests) { request in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(request.userName)
                                                    .font(.headline)
                                                Text("Requested to join \(request.clanName)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                Text("Requested at: \(formattedDate(from: request.createdAt))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            VStack(spacing: 8) {
                                                Button(action: {
                                                    sheetManager.acceptRequest(requestId: request.id)
                                                }) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.green)
                                                }

                                                Button(action: {
                                                    sheetManager.declineRequest(requestId: request.id)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.white) // Set request cards with white background
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Subtle shadow
                                }
                            }
                            .padding()
                        }
                        
                    }

                    Spacer(minLength: 20)

                    // Close button
                    Button(action: {
                        sheetManager.showSheet = false
                    }) {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground)) // Set the sheet's background to white
                .navigationTitle("Join Requests")
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
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("You are a member of")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            // Display clan name or placeholder if unavailable
                            if let clanDetails = appState.clanDetails {
                                Text(clanDetails.name)
                                    .font(.title)
                                    .fontWeight(.heavy)
                            } else {
                                Text("Loading clan name...")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        NavigationLink(destination: SearchClansView()) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top)
                    
                    // Challenge Points
                    if let clanDetails = appState.clanDetails {
                        HStack {
                            Text("Challenge Points")
                                .font(.headline)
                                .foregroundColor(.yellow)
                            Spacer()
                            HStack {
                                Image(systemName: "bolt.circle")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 24))
                                Text("\(Int(clanDetails.challengePoints))") // Display challenge points
                                    .font(.system(size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            .padding(8)
                            .background(Color(.white))
                            .cornerRadius(8)
                            .shadow(color: Color.yellow, radius: 2, x: 0, y: 0)
                        }
                        .padding(.bottom)
                    } else {
                        Text("Loading challenge points...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    
                    
                    // Current Challenge Section
                    if let clanDetails = appState.clanDetails {
                        HStack {
                            NavigationLink(destination: ClanChallengesView(clanId: clanDetails.id)) {
                                Text("View Clan Challenges")
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
                            
                            // Leave button with confirmation alert
                            Button(action: {
                                showLeaveAlert = true // Trigger alert
                            }) {
                                Text("Leave")
                                    .padding()
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .alert("Leave Clan?", isPresented: $showLeaveAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Leave", role: .destructive) {
                                    leaveClan()
                                }
                            } message: {
                                Text("Are you sure you want to leave this clan? This action cannot be undone.")
                            }
                        }
                        
                    } else {
                        Text("Loading challenges...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    
                    // Members Section
                    if let clanDetails = appState.clanDetails {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Members")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Spacer()
                                
                                if let clanMemberDetails = appState.clanMemberDetails, clanMemberDetails.role.lowercased() == "leader" {
                                    Image(systemName: "bell")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            sheetManager.fetchJoinRequests(for: clanMemberDetails.clanId)
                                        }
                                }
                            }
                            
                            ForEach(clanDetails.members, id: \.id) { member in
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
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.top)
                    } else {
                        Text("Loading members...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .refreshable {
                appState.refreshClanDetails()
            }
        }
        
    }
    
    // Function to handle leaving the clan
    func leaveClan() {
        guard let userId = appState.userId, let clanId = appState.clanMemberDetails?.clanId else {
            print("Missing userId or clanId")
            return
        }

        let url = URL(string: "http://10.228.227.249:5085/api/clan/\(clanId)/leave/\(userId)")! // Update with your actual endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error leaving clan: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    // Reset the AppState to reflect no clan membership
                    appState.clanMemberDetails = nil
                    appState.clanDetails = nil
                    appState.refreshClanDetails() // Optional: Ensure the state is fully refreshed
                }
            } else {
                print("Failed to leave clan: Unexpected status code")
            }
        }.resume()
    }
    
    func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short

        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        }
        return "Unknown Date"
    }
}


#Preview {
    ClanView()
        .environmentObject(AppState())
}
