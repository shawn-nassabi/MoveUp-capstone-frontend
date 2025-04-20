//
//  ClanDetailsView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/8/24.
//

import SwiftUI

struct ClanDetailsView: View {
    @EnvironmentObject var appState: AppState
    
    let clan: Clan
    @Binding var showClanDetails: Bool
    
    // For when a request is sent
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(clan.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text("Description")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Text(clan.description)
                .padding(.bottom, 10)

            Text("Location")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Text(clan.location)
                .padding(.bottom, 10)
            
            Text("Challenge Points")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.bottom, 5)
            
            HStack {
                Image(systemName: "bolt.circle")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
                Text("\(Int(clan.challengePoints))")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
            .padding(5)
            .background(Color(.white))
            .cornerRadius(8)
            .shadow(color: Color.yellow, radius: 2, x: 0, y: 0)
            

            Text("Members")
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(clan.members, id: \.memberId) { member in
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
            }

            Spacer()
            
            Button(action: {
                // Send a join request to the clan
                sendJoinRequest()
            }) {
                Text("Send Join Request")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.bottom, 10)

            Button(action: {
                // Close the modal
                showClanDetails = false
            }) {
                Text("Close")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
    }
    
    func sendJoinRequest() {
        guard let userId = appState.userId else {
            // Handle the case where the userId is not available
            alertTitle = "Error"
            alertMessage = "UserId unavailable. Please try again."
            showAlert = true
            return
        }
        
        guard let url = URL(string: "\(API.baseURL)/api/clan/\(clan.id)/invite/\(userId)") else {
            alertTitle = "Error"
            alertMessage = "Invalid server URL."
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertTitle = "Error"
                    alertMessage = "Failed to send join request: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertTitle = "Success"
                    alertMessage = "Your join request has been sent successfully!"
                } else {
                    alertTitle = "Error"
                    alertMessage = "Failed to send join request. Please try again later."
                }
                showAlert = true
            }
        }.resume()
    }
}
