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
  
  func testCall() async {
    if (tests != nil){
      return
    }
    do {
      let test = try await APIManager.shared.testAPI(lastPeriodStart: "2025-11-20T00:00:00Z")
      DispatchQueue.main.async {
        self.tests = test
        self.isLoading = false
      }
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
  
