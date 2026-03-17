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

struct TimelineEntry: Identifiable, Hashable {
    let id = UUID()
    let type: EntryType
    let name: String
    let date: Date
    let value: String?
    let unit: String?
    let phase: String?
}

enum EntryType {
    case trackable
    case symptom
}



@MainActor
class HealthInfoViewModel: ObservableObject {
  
  // 1. In the HealthDataViewModel we define all the properties to store the latest values for step count, heart rate, and active energy burned.
  @Published var menstrualData: [MenstrualCycle] = [] //fetched from the health kit 
  var cramps: HKQuantitySample?
  @Published var isAuthorized: Bool = false
  @Published var state: LoadState = .idle
  @Published var errorMessage: String?
  
  @Published var showSubmissionSheet: Bool = false
  @Published var showDailyCheckInSheet: Bool = false
  @Published var showErrorAlert: Bool = false
  @Published var dataFetched: Bool = true
  @Published var groupedTimeline: [(date: Date, items: [TimelineEntry])] = []
  @Published var myInfo: UserInfoResponse?
  
  var commonSymptoms: [String] = Symptoms.allCases.map(\.displayName)

  
  init() {
    Task { await requestAuthorization() }
  }
  
  func getUserInfo() async{
    if (myInfo != nil){
      return
    }
    do{
      let response = try await APIManager.shared.getUserInfo()
      DispatchQueue.main.async {
        self.myInfo = response
        print("🐞🧍 MyInfo: \(response.current_cycle)")
        let timeline = self.buildTimeline(
            trackables: response.trackables,
            symptoms: response.symptoms
        )

        self.groupedTimeline = self.groupByDate(entries: timeline)
      }
    } catch { print("API Error:", error) }
  }
  
  
  
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
//        print("🐞🐞🩸Fetched Menstrual Samples! \n  \(sample)")
        self.dataFetched = true
        return
      }

    } else {
      self.errorMessage = "We don't have access to your Health Information! Make sure to allow access to your Health info in your Settings."
      state = .notAuthorized
      self.dataFetched = false
      
    }
  }
  
  func saveData(flow: Int, date: Date, symptoms: [Symptoms]) async {
    HealthKitManager.shared.saveMenstrualFlow(flow: flow , start: date, end: date)
    print("sent flow to healthkit, now sending to server")
    await sendSymptoms(symptoms: symptoms, date: date)
    
  }
  
  func sendSymptoms(symptoms: [Symptoms], date: Date) async {
      guard !symptoms.isEmpty else { return }

    let dateString = DateHelpers.formatDateForAPI(date)

      for symptom in symptoms {
          let payloadDict: [String: Any] = [
              "symptom": symptom.id,  // UUID string
              "date": dateString
          ]

          do {
              let jsonData = try JSONSerialization.data(withJSONObject: payloadDict, options: [])
              print("Sending JSON payload:", String(data: jsonData, encoding: .utf8) ?? "")

              let response = try await APIManager.shared.logSymptom(body: jsonData)
              print("✅ Logged symptom \(symptom) — response:", response)
          } catch {
              print("❌ Failed to log symptom \(symptom) — error:", error)
          }
      }
  }
  func sendTrackables(_ items: [TrackableItem]) async {
      for item in items {
          do {
              let response = try await APIManager.shared.logTrackable(
                  name: item.name,
                  valueNumeric: item.value_numeric ?? 0.0
              )
              print("✅ Logged \(item.name):", response)
          } catch {
              print("❌ Failed \(item.name):", error)
          }
      }
  }
  
  func parseDate(_ string: String) -> Date {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.date(from: string) ?? Date()
  }
  
  
  func mapTrackables(_ trackables: [UserTrackables]) -> [TimelineEntry] {
      trackables.map {
          TimelineEntry(
              type: .trackable,
              name: $0.name,
              date: parseDate($0.date),
              value: $0.value_numeric ?? $0.value_text,
              unit: $0.unit ?? "",
              phase: $0.phase ?? ""
          )
      }
  }
  
  func mapSymptoms(_ symptoms: [UserSymptomsResponse]) -> [TimelineEntry] {
      symptoms.map {
          TimelineEntry(
              type: .symptom,
              name: $0.symptom_name,
              date: parseDate($0.date),
              value: nil,
              unit: nil,
              phase: $0.phase ?? ""
          )
      }
  }
  
  func buildTimeline(trackables: [UserTrackables], symptoms: [UserSymptomsResponse]) -> [TimelineEntry] {
      let combined = mapTrackables(trackables) + mapSymptoms(symptoms)

      return combined.sorted { $0.date > $1.date } // newest first
  }
  
  func groupByDate(entries: [TimelineEntry]) -> [(date: Date, items: [TimelineEntry])] {
      let grouped = Dictionary(grouping: entries) { entry in
          Calendar.current.startOfDay(for: entry.date)
      }

      return grouped
          .map { ($0.key, $0.value) }
          .sorted { $0.date > $1.date }
  }
  
}


