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
    // Sample data for members
    @State private var members: [Member] = [
        Member(id: "1", userName: "John_Doe", role: "LEADER"),
        Member(id: "2", userName: "Shawn_Nassabi", role: "MEMBER"),
        Member(id: "3", userName: "Jackie_Chan", role: "MEMBER"),
        Member(id: "4", userName: "Emily_Rose", role: "MEMBER")
    ]

    var body: some View {
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
                        VStack {
                            Text("GOAL: 100,000")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.bottom, 2)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Steps\nChallenge")
                                        .font(.system(size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .padding(.bottom)
                                }
                                
                                Spacer()
                                
                                
                                // Circular Progress Bar
                                HStack{
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("25,000")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                        Text("needed")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
   
                                    ZStack {
                                        // Background Circle
                                        Circle()
                                            .stroke(
                                                Color.gray.opacity(0.2),
                                                lineWidth: 10
                                            )
                                            .frame(width: 70, height: 70)
                                        
                                        // Foreground Circle showing progress
                                        Circle()
                                            .trim(from: 0.0, to: 0.75) // 75% progress
                                            .stroke(
                                                Color.green,
                                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                            )
                                            .rotationEffect(.degrees(-90)) // Start at the top
                                            .frame(width: 70, height: 70)
                                        
                                        // Percentage Label
                                        Text("75%")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }

                                }
                                .padding(.bottom)
                                
                            }
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.white))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
                        

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
