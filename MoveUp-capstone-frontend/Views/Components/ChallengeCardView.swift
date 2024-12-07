//
//  ChallengeCardView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/6/24.
//

import SwiftUI

struct ChallengeCardView: View {
    let goal: String
    let title: String
    let progress: Double
    let needed: String
    
    var body: some View {
        VStack {
            Text("GOAL: \(goal)")
                .font(.system(size: 10))
                .foregroundColor(.green)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 2)
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.bottom)
                }
                Spacer()

                // Circular Progress Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(needed)")
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
                            .trim(from: 0.0, to: progress) // Progress from 0 to 1
                            .stroke(
                                Color.green,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90)) // Start at the top
                            .frame(width: 70, height: 70)

                        // Percentage Label
                        Text("\(Int(progress * 100))%")
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
    }
}
