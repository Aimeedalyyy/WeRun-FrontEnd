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
  @Published var showAddRaceGoalModal: Bool = false
  @Published var myCalendar: [CycleDay]?
  
  
  
  
  func getDaysAdvice(date: Date) async {
    do{
      let response = try await APIManager.shared.fetchTodaysAdvice(date: date)
      await MainActor.run {
          self.adviceByDate[Calendar.current.startOfDay(for: date)] = response
          print("🐞🧍 myAdviceforDay: \(response)")
      }
    } catch { print("API Error:", error) }
  }
  
  
  func getUserCalendar() async {
    Task.detached {
        do {
            let response = try await APIManager.shared.fetchCycleCalendar()
            await MainActor.run {
                self.myCalendar = response
                print("🐞🧍 myCalendar: \(response)")
            }
        } catch {
            print("API Error:", error)
        }
    }
  }

}



