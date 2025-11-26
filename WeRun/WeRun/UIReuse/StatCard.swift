//
//  StatCard.swift
//  WeRun
//
//  Created by Aimee Daly on 26/11/2025.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentgreen.opacity(0.8))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.accentgreen.opacity(0.8))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.accentgreen)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.accentgreen.opacity(0.8))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentgreen.opacity(0.2))
        .cornerRadius(15)
    }
}
