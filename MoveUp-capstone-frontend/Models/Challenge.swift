//
//  Challenge.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//

struct Challenge: Identifiable, Codable {
    let id: String
    let clanId: String
    let challengeName: String
    let challengeDescription: String
    let dataType: String
    let goal: Float
    let isCompleted: Bool
    let totalProgress: Float
    let startDate: String
    let endDate: String
}
