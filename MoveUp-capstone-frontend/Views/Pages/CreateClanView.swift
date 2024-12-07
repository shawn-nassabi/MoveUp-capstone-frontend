//
//  CreateClanView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//

import SwiftUI

struct CreateClanView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var isLoading: Bool = false // Show loading indicator during API call
    @State private var errorMessage: String? = nil // To display errors
    @State private var showFieldErrors: Bool = false // Flag to show field validation errors

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Clan Name Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clan Name")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter clan name", text: $name)
                        .padding()
                        .background(name.isEmpty && showFieldErrors ? Color.red.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: name) { oldValue, newValue in
                            if newValue.count > 30 { // Limit to 30 characters
                                name = String(newValue.prefix(30))
                            }
                        }
                    if name.isEmpty && showFieldErrors {
                        Text("Clan name is required.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                // Clan Description Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clan Description")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter description", text: $description)
                        .padding()
                        .background(description.isEmpty && showFieldErrors ? Color.red.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: description) { oldValue, newValue in
                            if newValue.count > 150 { // Limit to 150 characters
                                description = String(newValue.prefix(150))
                            }
                        }
                    if description.isEmpty && showFieldErrors {
                        Text("Clan description is required.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                // Clan Location Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter location", text: $location)
                        .padding()
                        .background(location.isEmpty && showFieldErrors ? Color.red.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: location) { oldValue, newValue in
                            if newValue.count > 50 { // Limit to 50 characters
                                location = String(newValue.prefix(50))
                            }
                        }
                    if location.isEmpty && showFieldErrors {
                        Text("Location is required.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                // Error Message Display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }

                // Create Clan Button
                Button(action: {
                    if name.isEmpty || description.isEmpty || location.isEmpty {
                        showFieldErrors = true // Show validation errors
                    } else {
                        createClan()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Create Clan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Create a Clan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func createClan() {
        guard let userId = appState.userId else {
            errorMessage = "User ID is missing. Please log in again."
            return
        }

        isLoading = true
        errorMessage = nil

        let url = URL(string: "http://10.228.227.249:5085/api/clan")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "name": name,
            "description": description,
            "location": location,
            "leaderId": userId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request body."
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                // Success: Refresh the app state and navigate back to ClanView
                DispatchQueue.main.async {
                    appState.refreshClanDetails() // Refresh clan details
                    presentationMode.wrappedValue.dismiss() // Go back to ClanView
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to create clan. Please try again."
                }
            }
        }.resume()
    }
}

#Preview {
    CreateClanView()
        .environmentObject(AppState())
}
