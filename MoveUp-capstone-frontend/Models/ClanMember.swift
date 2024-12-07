//
//  ClanMember.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/6/24.
//

struct ClanMember: Identifiable, Codable, Hashable {
    let memberId: String
    let userId: String
    let clanId: String
    let userName: String
    let role: String
    
    var id: String { memberId } // Conforms to Identifiable using memberId
}
