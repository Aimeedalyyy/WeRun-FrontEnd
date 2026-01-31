//
//  HealthInfoViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 26/11/2025.
//


import Foundation
import HealthKit
import Observation
import SwiftData

@MainActor
class RunningViewModel: ObservableObject {
  @Published var isAuthorized: Bool = false
  @Published var state: LoadState = .idle
  @Published var isLocationAuthorized = false
  @Published var errorMessage: String?
  
  @Published var showSubmissionSheet: Bool = false
  @Published var showErrorAlert: Bool = false
  
  
  @Published var showingAlert = false
  @Published var alertMessage = ""
  @Published var showHistory = false
  @Published var selectedDate = Date()
  @Published var showDatePicker = false
  @Published var completedWorkoutData: (distance: Double, duration: TimeInterval, calories: Double, startDate: Date, pace: Double)?
  @Published var showWorkoutSummary = false
  @Published var motivationLevel: Int = 5
  
  @Published var showMotivationInput = false
  @Published var showStopConfirmation = false

  

  
  
  
  @Published var workoutHistory: [HKWorkout] = []
  
  
  func fetchAllRunningWorkout() async {
    if self.isAuthorized {
//      print(HealthKitManager.shared.fetchAllRunningWorkouts { _ in })
      return
    } else {
      self.errorMessage = "We don't have access to your Health Information! Make sure to allow access to your Health info in your Settings."
      state = .notAuthorized
      
    }
  }
  
  func finishWorkout() {
    let workoutData = WorkoutManager.shared.stopWorkout()
      
      // Store workout data for summary
      completedWorkoutData = (
          distance: workoutData.distance,
          duration: workoutData.duration,
          calories: workoutData.calories,
          startDate: workoutData.startDate,
          pace: WorkoutManager.shared.pace
      )
      
      // Save to HealthKit
      HealthKitManager.shared.saveWorkout(
          distance: workoutData.distance,
          duration: workoutData.duration,
          calories: workoutData.calories,
          startDate: workoutData.startDate
      ) { success in
          if success {
            self.alertMessage = "Workout saved to Apple Health!"
          } else {
              self.alertMessage = "Failed to save workout to Apple Health."
          }
          self.showingAlert = true
          
          // Show summary after alert
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showWorkoutSummary = true
          }
      }
      
      // Log workout to backend
      Task {
          do {
              // Format dates for API
              let dateFormatter = ISO8601DateFormatter()
              dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
              
              let runDate = dateFormatter.string(from: workoutData.startDate)
              
              // You'll need to get the last period start from somewhere
              // For now using a placeholder - replace with actual user data
              let lastPeriodStart = "2025-11-20T00:00:00Z" // TODO: Get from user profile/settings
              
              let response = try await APIManager.shared.logRun(
                  run: RunEntryRequest(
                      date: runDate,
                      pace: 1.1,//WorkoutManager.shared.pace,
                      distance: 1,//WorkoutManager.shared.distance / 1000, // Convert meters to km
                      motivation_level: motivationLevel,
                      last_period_start: lastPeriodStart
                  )
              )
              
              print("✅ Workout logged successfully: \(response)")
              
              DispatchQueue.main.async {
                  self.alertMessage = "Workout saved and logged successfully!"
                  self.showingAlert = true
              }
              
          } catch {
              print("❌ Error logging workout: \(error)")
              
              DispatchQueue.main.async {
                  self.alertMessage = "Workout saved locally but failed to sync with server."
                  self.showingAlert = true
              }
          }
      }
  }
  

}
