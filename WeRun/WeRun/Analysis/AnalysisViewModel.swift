//
//  AnalysisViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 01/12/2025.
//

import SwiftUI
import Foundation

class AnalysisViewModel: ObservableObject{
  
  @Published var analysisResponse: PhaseComparisonResponse?
  @Published var isLoading = true
  @Published var phases: [PhaseStats] = []

  
  func getAnalysis() async {
    guard let url = URL(string: baseURL + "all-phases-comparison/") else {
      print("⚠️⚠️ Invalid URL ⚠️⚠️")
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let analysisResponse = try JSONDecoder().decode(PhaseComparisonResponse.self, from: data)
      print(analysisResponse)
      await MainActor.run {
          self.analysisResponse = analysisResponse
          self.phases = analysisResponse.phases
          self.isLoading = false
      }
    } catch {
      print("⚠️⚠️ Failed to load test: \(error) ⚠️⚠️")
    }
  }
  
  func getPaceStatString(phase: PhaseStats) -> returnString {
      // Find the phase with the fastest pace (lowest value)
      guard let fastestPhase = phases.min(by: { $0.current_avg_pace < $1.current_avg_pace }) else {
          return returnString(string: "Pace data unavailable")
      }
      
    let isFastest = phase.phase == fastestPhase.phase
      let percentSlowerThanFastest = ((phase.current_avg_pace - fastestPhase.current_avg_pace) / fastestPhase.current_avg_pace) * 100
      
      if isFastest {
        return returnString(string: "Your fastest phase! Keep crushing it!", isPeak: true)
      } else if percentSlowerThanFastest < 10 {
          return returnString(string: "Nearly your best! Only \(String(format: "%.1f", percentSlowerThanFastest))% slower than your peak")
      } else if percentSlowerThanFastest < 25 {
          return returnString(string: "Solid pace - \(String(format: "%.1f", percentSlowerThanFastest))% off your peak, but still strong")
      } else {
          return returnString(string: "Take it easy - your body needs different energy levels throughout your cycle")
      }
  }

  func getMotivationStatString(phase: PhaseStats) -> returnString {
      // Find the phase with highest motivation
      guard let mostMotivatedPhase = phases.max(by: { $0.current_avg_motivation < $1.current_avg_motivation }) else {
        return returnString(string: "Motivation data unavailable")
      }
      
      let isMostMotivated = phase.phase == mostMotivatedPhase.phase
      let motivationDiff = phase.current_avg_motivation - mostMotivatedPhase.current_avg_motivation
      
      if isMostMotivated {
          return  returnString(string: "Peak motivation phase! You're feeling your strongest!", isPeak: true)
      } else if motivationDiff > -1 {
          return returnString(string: "Feeling great! Nearly at your peak motivation")
      } else if motivationDiff > -2 {
          return returnString(string: "Good energy levels - you're staying consistent")
      } else {
          return returnString(string: "Lower energy is normal - you still showed up and that's what matters!")
      }
  }
  
  func getPaceValueString(value: Double) -> String{
    return "average pace: \(value)/km"
  }
  
  func getMotivationValueString(value: Double) -> String{
    return "average motivation level: \(value)/10"
  }
  
  
  
  struct returnString{
    var string: String
    var isPeak: Bool?
  }
}
