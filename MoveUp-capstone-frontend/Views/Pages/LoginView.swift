//
//  LoginView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 4/23/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    @State private var password = ""
    @State private var errorMsg = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // MoveUp logo header
                HeaderView()

                // Login card
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)

                    if isLoading {
                        ProgressView()
                    } else {
                        Button(action: { login() }) {
                            Text("Log In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.teal, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(username.isEmpty || password.isEmpty)
                    }

                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
            }
        }
    }

    private func login() {
        errorMsg = ""
        isLoading = true
        ApiManager.shared.login(username: username, password: password) { success, msg, json in
            DispatchQueue.main.async {
                isLoading = false
                if success, let json = json,
                   let uid = json["userId"] as? String,
                   let wallet = json["walletAddress"] as? String {
                    appState.saveSession(userId: uid, wallet: wallet)
                    appState.fetchUserData()         // ← pull profile (username, age, etc)
                    appState.fetchBlockchainData()   // ← pull points/tokens
                } else {
                    errorMsg = msg ?? "Unknown error"
                }
            }
        }
    }
}
