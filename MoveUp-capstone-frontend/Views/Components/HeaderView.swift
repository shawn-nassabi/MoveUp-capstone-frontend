//
//  HeaderView.swift
//  MoveUp-capstone-frontend
//
//  Created by Shawn Nassabi on 11/29/24.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("MoveUp")
              .font(Font.custom("Pacifico-Regular", size: 24))
              .multilineTextAlignment(.center)
              .foregroundStyle(
                  LinearGradient(
                    colors: [Color.teal, Color.blue],
                      startPoint: .leading,
                      endPoint: .trailing
                  )
              )
            
        }
        .padding(.bottom)
        
        
    }
}
