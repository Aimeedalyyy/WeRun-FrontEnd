//
//  CalendarViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 11/03/2026.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
  @Published var selectedDate: Date?
  @Published var myAdviceforDay: AdviceResponse?
  @Published var adviceByDate: [Date: AdviceResponse] = [:]
  
  
  
  
  func getDaysAdvice(date: Date) async {
    do{
      let response = try await APIManager.shared.fetchTodaysAdvice(date: date)
      await MainActor.run {
          self.adviceByDate[Calendar.current.startOfDay(for: date)] = response
          print("🐞🧍 myAdviceforDay: \(response)")
      }
    } catch { print("API Error:", error) }
  }
}

