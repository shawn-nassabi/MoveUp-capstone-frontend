//
//  Clan.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//

import Foundation

struct Clan: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let location: String
    let members: [ClanMember]
}
