//
//  AnalysisCard.swift
//  WeRun
//
//  Created by Aimee Daly on 06/12/2025.
//

import SwiftUI

struct PostCard: View {
    let phase: String
    let colour: Color

    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("You are currently in your \(phase) phase")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colour)
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colour.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
              .stroke(colour, lineWidth: 2)
        )
    }
}

#Preview {
  PostCard(phase: "Menstrual", colour: .accentgreen)
}

