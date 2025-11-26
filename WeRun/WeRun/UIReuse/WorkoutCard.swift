//
//  WorkoutCard.swift
//  WeRun
//
//  Created by Aimee Daly on 26/11/2025.
//
struct Workout {
  let test: String
  
}

import SwiftUI
import HealthKit

struct WorkoutCard: View {
    let workout: HKWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundColor(.accentgreen)
                Text(workout.startDate, style: .date)
                    .font(.headline)
                    .foregroundColor(.accentgreen)
                Spacer()
                Text(workout.startDate, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.accentgreen.opacity(0.8))
            }
            
            Divider()
            .background(Color.accentgreen.opacity(0.3))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.accentgreen.opacity(0.7))
                    Text(String(format: "%.2f km", (workout.totalDistance?.doubleValue(for: .meter()) ?? 0) / 1000))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentgreen)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.accentgreen.opacity(0.7))
                    Text(formatDuration(workout.duration))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentgreen)
                }
            }
        }
        .padding()
        .background(Color.accentgreen.opacity(0.15))
        .cornerRadius(15)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}




