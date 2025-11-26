//
//  AppViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 25/11/2025.
//


import Foundation

class AppViewModel: ObservableObject {
  
  @Published var tests: Test = Test(test_name: "", test_number: 0)
  @Published var isLoading = true
  
  func testCall() async {
    guard let url = URL(string: "http://127.0.0.1:8000/api/test/") else {
      print("⚠️⚠️ Invalid URL ⚠️⚠️")
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let test = try JSONDecoder().decode(Test.self, from: data)
      print(tests)
      await MainActor.run {
          self.tests = test
          self.isLoading = false
      }
    } catch {
      print("⚠️⚠️ Failed to load test: \(error) ⚠️⚠️")
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
  
