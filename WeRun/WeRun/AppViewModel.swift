//
//  AppViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 25/11/2025.
//

let baseURL =  "http://0.0.0.0:8000/api/"


import Foundation
import SwiftUI


class AppViewModel: ObservableObject {
  
  @Published var tests: TestResponse?
  @Published var isLoading = true
  @Published var myInfo: UserInfoResponse?
  @Published var myCalendar: [CycleDay]?
  @Published var myAdvice: AdviceResponse?
  @Published var raceGoal: RaceGoalResponse?
  @Published var submitRaceGoal: RaceGoalRequest?
  @Published var submitResponse: SubmitRaceGoalReponse?
  
  
  func getUserInfo() async{
    if (myInfo != nil){
      return
    }
    do{
      let response = try await APIManager.shared.getUserInfo()
      
      
      DispatchQueue.main.async {
        self.myInfo = response
        print("🐞🧍 MyInfo: \(response.current_cycle)")
      }
    } catch { print("API Error:", error) }
  }
  
  func getRaceGoal() async {
    if (raceGoal != nil){
      return
    }
    do{
      let response = try await APIManager.shared.getRaceGoal()
      DispatchQueue.main.async {
        self.raceGoal = response
        self.isLoading = false
        print("🐞🧍 raceGoal: \(response)")
      }
    } catch { print("API Error:", error) }
  }
  
  func submitRaceGoal() async{
    if (submitResponse != nil){
      return
    }

    do{
      if let submitRaceGoal = self.submitRaceGoal{
        let response = try await APIManager.shared.submitRaceGoal(race: submitRaceGoal)
        DispatchQueue.main.async {
          self.submitResponse = response
          print("🐞🏃‍♀️ Submitted race goal: \(response)")
        }
      }
    } catch { print("API Error:", error) }
  }

//  func getUserCalendar() async {
//    do{
//      let response = try await APIManager.shared.fetchCycleCalendar()
//      DispatchQueue.main.async {
//        self.myCalendar = response
//        self.isLoading = false
//        print("🐞🧍 myCalendar: \(response)")
//      }
//    } catch { print("API Error:", error) }
//  }
  
  func getTodaysAdvice() async {
    do{
      let response = try await APIManager.shared.fetchTodaysAdvice(date: nil)
      DispatchQueue.main.async {
        self.myAdvice = response
        print("🐞🧍 myAdvice: \(response)")
      }
    } catch { print("API Error:", error) }
  }

    
  
  
  func testCall() async {
    if (tests != nil){
      return
    }
    do {
      let test = try await APIManager.shared.testAPI(lastPeriodStart: "2026-02-19T00:00:00Z")
      DispatchQueue.main.async {
        self.tests = test
        
      }
      print("🐞 test api: \(String(describing: self.tests))")
    }
    catch { print("API Error:", error) }
  }
  
  func getPhaseColor(for phase: String) -> Color {
      switch phase.lowercased() {
      case "menstrual":
        return .accentRed
      case "follicular":
          return .accentgreen
      case "ovulatory":
        return .accentPink
      case "luteal":
          return .accentPurple
      default:
          return .accentRed
      }
  }
  
}
  
extension URLRequest {
    mutating func setBasicAuth(username: String, password: String) {
        let credentials = "\(username):\(password)"
        if let data = credentials.data(using: .utf8) {
            let base64Credentials = data.base64EncodedString()
            setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
    }
}
  
