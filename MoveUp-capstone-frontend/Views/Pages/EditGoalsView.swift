//
//  EditGoalsView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/8/24.
//


import SwiftUI

struct EditGoalsView: View {
    @EnvironmentObject var appState: AppState
    @State private var goals: [String: String] = [:] // Temporary state for editing
    
    @State private var showAlert: Bool = false // State for showing the confirmation alert
    @FocusState private var focusedGoal: String? // Tracks which TextField is focused

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Your Health Goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Customize your daily health targets to suit your lifestyle.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(appState.healthGoals.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key.capitalized.replacingOccurrences(of: "_", with: " "))
                                    .font(.headline)
                                
                                Spacer()

                                TextField("Enter goal", text: Binding(
                                    get: { goals[key] ?? "\(appState.healthGoals[key] ?? 0)" },
                                    set: { goals[key] = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 100)
                                .keyboardType(.numberPad)
                                .focused($focusedGoal, equals: key) // Bind focus state to each goal
                                .onChange(of: goals[key] ?? "") { oldValue, newValue in
                                    goals[key] = newValue.filter { $0.isNumber } // Remove non-numeric characters
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }

                Spacer()

                // Save Button
                Button(action: {
                    saveGoals()
                    showAlert = true // Show confirmation alert
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)

                // Cancel Button
                Button(action: cancelChanges) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                .padding(.top)
            }
            .padding()
            .padding(.horizontal, 10)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedGoal = nil // Dismiss keyboard
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Changes Saved"),
                    message: Text("Your health goals have been successfully updated."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            initializeGoals()
        }
    }

    // Initialize temporary state with current goals
    private func initializeGoals() {
        goals = appState.healthGoals.mapValues { "\($0)" }
    }

    // Save changes to AppState
    private func saveGoals() {
        for (key, value) in goals {
            if let intValue = Int(value) {
                appState.healthGoals[key] = intValue
            }
        }
    }

    // Cancel changes and reset to original state
    private func cancelChanges() {
        initializeGoals()
    }
}

#Preview {
    EditGoalsView()
        .environmentObject(AppState())
}
