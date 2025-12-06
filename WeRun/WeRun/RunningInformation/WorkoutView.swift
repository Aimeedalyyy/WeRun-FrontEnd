//
//  WorkoutView.swift
//  WeRun
//
//  Created by Aimee Daly on 06/12/2025.
//

import SwiftUI


struct WorkoutView: View {
    @ObservedObject private var workoutManager = WorkoutManager.shared
    @ObservedObject var viewModel: RunningViewModel 
    
    var body: some View {
        workoutView
    }
    
    private var workoutView: some View {
        VStack(spacing: 30) {
            // Stats Grid
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    StatCard(
                        title: "Distance",
                        value: String(format: "%.2f", workoutManager.distance / 1000),
                        unit: "km",
                        icon: "location.fill"
                    )
                    
                    StatCard(
                        title: "Duration",
                        value: formatTime(workoutManager.duration),
                        unit: "",
                        icon: "clock.fill"
                    )
                }
                
                HStack(spacing: 20) {
                    StatCard(
                        title: "Pace",
                        value: String(format: "%.1f", workoutManager.pace),
                        unit: "min/km",
                        icon: "speedometer"
                    )
                    
                    StatCard(
                        title: "Calories",
                        value: String(format: "%.0f", workoutManager.calories),
                        unit: "kcal",
                        icon: "flame.fill"
                    )
                }
            }
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 30) {
                if workoutManager.isPaused {
                    Button(action: {
                        workoutManager.resumeWorkout()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.green)
                    }
                } else {
                    Button(action: {
                        workoutManager.pauseWorkout()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.yellow)
                    }
                }
                
                Button(action: {
                    viewModel.showStopConfirmation = true
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // Add the formatTime function
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
