//
//  ClanCardView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 12/7/24.
//
import SwiftUI

struct ClanCardView: View {
    let clan: ClanSearchModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(clan.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(clan.location)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text("\"\(clan.description)\"")
                        .font(.subheadline)
                        .lineLimit(2)
                }
                Spacer()
                HStack {
                    Image(systemName: "bolt.circle")
                        .foregroundColor(.yellow)
                        .font(.system(size: 20))
                    Text("\(clan.challengePoints)")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    ClanCardView(clan: ClanSearchModel(id: "1" ,name: "Abu Dhabi Champions", description: "Join us if you are driven to win!", location: "Abu Dhabi", challengePoints: 10000))
}
