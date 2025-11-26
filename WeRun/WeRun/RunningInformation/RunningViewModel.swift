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
  
  
  @Published var workoutHistory: [HKWorkout] = []
  
  
  func fetchAllRunningWorkout() async {
    if self.isAuthorized {
      print(HealthKitManager.shared.fetchAllRunningWorkouts { _ in })
      return
    } else {
      self.errorMessage = "We don't have access to your Health Information! Make sure to allow access to your Health info in your Settings."
      state = .notAuthorized
      
    }
  }
}
