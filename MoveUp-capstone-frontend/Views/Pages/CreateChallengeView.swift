//
//  CreateChallengeView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//

import SwiftUI

struct CreateChallengeView: View {
    let clanId: String
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    @State private var dataType: String = "steps" // Default selection
    @State private var challengeName: String = ""
    @State private var challengeDescription: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    let dataTypes = ["steps", "calories", "sleep"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Create a New Challenge")
                .font(.system(size: 24))
                .fontWeight(.heavy)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Note: The challenge goal is automatically calculated based on the selected health metric and the number of members in your clan.")
                .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading) // Align text to the left for better readability
                    .lineLimit(nil) // Allow unlimited lines
                    .padding(.bottom)
            
            Text("Pick a health metric")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                // Data Type Picker
                Picker("Select Data Type", selection: $dataType) {
                    ForEach(dataTypes, id: \.self) { type in
                        Text(type.capitalized)
                            .padding()
                            
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(5)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(.bottom)
            
            Text("Name the challenge")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Challenge Name Input
            TextField("Challenge Name", text: $challengeName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: challengeName) { oldValue, newValue in
                    if newValue.count > 30 { // Limit to 50 characters
                        challengeName = String(newValue.prefix(30))
                    }
                }
                .padding(.bottom)
            
            
            Text("Enter a description")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Challenge Description Input
            TextField("Challenge Description", text: $challengeDescription)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: challengeDescription) { oldValue, newValue in
                    if newValue.count > 100 { // Limit to 50 characters
                        challengeDescription = String(newValue.prefix(100))
                    }
                }
                .padding(.bottom)

            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            // Submit Button
            Button(action: {
                createChallenge()
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Create Challenge")
                        .frame(maxWidth: .infinity)
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
            }
            .disabled(isLoading || challengeName.isEmpty || challengeDescription.isEmpty)

            Spacer()
        }
        .padding()
        .navigationTitle("New Challenge")
        .navigationBarTitleDisplayMode(.inline)
    }

    func createChallenge() {
        guard !challengeName.isEmpty, !challengeDescription.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        isLoading = true
        errorMessage = nil

        let url = URL(string: "\(API.baseURL)/api/clan/\(clanId)/challenge")! 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "clanId": clanId,
            "dataType": dataType,
            "challengeName": challengeName,
            "challengeDescription": challengeDescription
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
                    errorMessage = "Error creating challenge: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                // Success: Dismiss the view
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to create challenge. Please try again."
                }
            }
        }.resume()
    }
}


#Preview {
    CreateChallengeView(clanId: "123456789")
}
