//
//  RewardHistoryDto.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 4/20/25.
//

// RewardHistoryDto.swift

import Foundation

struct PointsRewardHistoryDto: Codable, Identifiable {
    let id: UUID
    let walletAddress: String
    let points: Int
    let timestamp: Date

    private enum CodingKeys: String, CodingKey {
        case id, walletAddress, points, timestamp
    }
}

// similarly for tokens:
struct TokenRewardHistoryDto: Codable, Identifiable {
    let id: UUID
    let walletAddress: String
    let tokens: Int
    let timestamp: Date
}
