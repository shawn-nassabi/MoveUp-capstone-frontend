//
//  JoinRequest.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/8/24.
//

struct JoinRequest: Identifiable, Codable {
    let id: String
    let clanName: String
    let userName: String
    let createdAt: String
}
