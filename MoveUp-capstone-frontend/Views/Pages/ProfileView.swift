//
//  ProfileView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct ProfileView: View {
    // Placeholder user details (you can replace these with dynamic data later)
    let username = "shawn_nassabi"
    let age = 22
    let location = "Dubai, UAE"
    let gender = "Male"

    var body: some View {
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
                Text(username)
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("Age: \(age)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text("Location: \(location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.gray)
                    Text("Gender: \(gender)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer() // Pushes everything to the top
        }
        .padding()
    }
}
