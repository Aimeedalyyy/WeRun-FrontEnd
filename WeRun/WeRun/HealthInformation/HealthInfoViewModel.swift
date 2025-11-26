//
//  appViewModel.swift
//  HealthKitApp
//
//  Created by Aimee Daly on 08/09/2025.
//

import Foundation
import HealthKit
import Observation
import SwiftData

let isoFormatter = ISO8601DateFormatter()


@MainActor
class HealthInfoViewModel: ObservableObject {
  
  // 1. In the HealthDataViewModel we define all the properties to store the latest values for step count, heart rate, and active energy burned.
  @Published var menstrualData: [MenstrualCycle] = []
  var cramps: HKQuantitySample?
  @Published var isAuthorized: Bool = false
  @Published var state: LoadState = .idle
  @Published var errorMessage: String?
  
  @Published var showSubmissionSheet: Bool = false
  @Published var showErrorAlert: Bool = false
  
  var commonSymptoms: [String] = Symptoms.allCases.map(\.displayName)

  
  init() {
    Task { await requestAuthorization() }
  }
  
  
  let mockCycles: [MenstrualCycle] = [
    MenstrualCycle(
        startDate: isoFormatter.date(from: "2025-06-13T23:00:00+0000")!,
        endDate: isoFormatter.date(from: "2025-06-16T23:00:00+0000")!,
        lengthInDays: 4
    ),
      MenstrualCycle(
          startDate: isoFormatter.date(from: "2025-07-12T23:00:00+0000")!,
          endDate:   isoFormatter.date(from: "2025-07-15T00:00:00+0100")!, // approximate end date from flowSamples
          lengthInDays: 2
      ),
      MenstrualCycle(
          startDate: isoFormatter.date(from: "2025-08-13T23:00:00+0000")!,
          endDate: isoFormatter.date(from: "2025-08-16T23:00:00+0000")!,
          lengthInDays: 3
      )
  ]
  
  func DateToDisplay(startDate: Date, endDate: Date) -> String {
    if DateHelpers.isToday(endDate) {
      let start = DateHelpers.formatDate(startDate)
      
      return "\(start) - Today"
    } else {
      let start = DateHelpers.formatDate(startDate)
      let end = DateHelpers.formatDate(endDate)
      return "\(start) - \(end)"
    }
    
    
  }
  
  

  
  // 2. When the view model is initialized, it immediately attempts to request HealthKit authorization using the requestAuthorization() method. If the permission is granted, it proceeds to fetch the health data.
  func requestAuthorization() async {
    do {
      let success = try await HealthKitManager.shared.requestAuthorization()
      state = .loading
      self.isAuthorized = success
      if success {
        await fetchMenstrualData()
        state = .loaded
      }
    } catch {
      self.errorMessage = error.localizedDescription
      state = .error(error)
      print(error)
    }
  }

  
  func fetchMenstrualData() async {
    if self.isAuthorized {
      if let sample = try? await HealthKitManager.shared.fetchLastNCycles(12){ //TODO: put that into user options
        self.menstrualData = sample.reversed()
        print(sample)
        return
      }

    } else {
      self.errorMessage = "We don't have access to your Health Information! Make sure to allow access to your Health info in your Settings."
      state = .notAuthorized
      
    }
  }
  
  func saveData(flow: Int, date: Date) async {
    HealthKitManager.shared.saveMenstrualFlow(flow: flow , start: date, end: date)
  }
  
  func sendSymptoms(symptoms: [Symptoms]) async {
    for symptom in symptoms {
      
      print(symptom)
      HealthKitManager.shared.saveSymptom(symptom)
    }
  }
}


