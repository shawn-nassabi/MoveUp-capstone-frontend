//
//  ClanSearch.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//

struct ClanSearchModel: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let location: String
    let challengePoints: Int
}
