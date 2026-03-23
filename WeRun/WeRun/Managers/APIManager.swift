//
//  APIManager.swift
//  WeRun
//
//  Created by Aimee Daly on 03/12/2025.
// let baseURL =  "http://0.0.0.0:8000/api/"  // Make sure it ends with '/'

import Foundation
import SwiftUI

struct DevConfig {
    static let username = "aimeedaly"
    static let password = "password"
    static let baseURL = "http://0.0.0.0:8000/"
}


import Foundation

class APIManager {
    @EnvironmentObject var authState: AppAuthState
    static let shared = APIManager()
    private init() {}
    


    
    // MARK: - Helper Request Function
  private func makeRequest<T: Codable>(
          endpoint: String,
          method: String,
          body: Data? = nil,
          retryOnAuthFailure: Bool = true
  ) async throws -> T {
    
    // 1️⃣ Build URL
    guard let url = URL(string: DevConfig.baseURL + endpoint) else {
      throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // 2️⃣ Get a valid (auto-refreshed if needed) token BEFORE sending
    //    Skip for unauthenticated endpoints like login/register
    if let token = try? await AuthManager.shared.validAccessToken() {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    if let body = body {
      request.httpBody = body
    }
    
    // 3️⃣ Perform network request
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let http = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    
    print("🐞 HTTP \(http.statusCode) — \(endpoint)")
    
    // 4️⃣ 401 = refresh token is also dead (validAccessToken already tried refreshing)
    //    Just log out — no point retrying
    if http.statusCode == 401 {
      AuthManager.shared.logout()
      throw URLError(.userAuthenticationRequired)
    }
    
    // 5️⃣ Handle other HTTP errors
    guard (200...299).contains(http.statusCode) else {
      let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw NSError(
        domain: "",
        code: http.statusCode,
        userInfo: [NSLocalizedDescriptionKey: errorText]
      )
    }
    
    // 6️⃣ Decode
    return try JSONDecoder().decode(T.self, from: data)
  }

    
    // MARK: - Endpoints
  
  // Login
    
    // Test API
    func testAPI(lastPeriodStart: String) async throws -> TestResponse {
      let body = try JSONEncoder().encode(["last_period_start": lastPeriodStart])
      return try await makeRequest(endpoint: "api/test/", method: "POST", body: body)
    }
    
    // Analysis: all phases comparison
    func getAnalysis() async throws -> PhaseComparisonResponse {
        return try await makeRequest(endpoint: "api/all-phases-comparison/", method: "GET")
    }
    
    // Phase comparison by phase name
    func getPhaseComparison(for phase: String) async throws -> PhaseStats {
        return try await makeRequest(endpoint: "api/phase-comparison/\(phase)/", method: "GET")
    }
    
    // Sync period
    func syncPeriod(lastPeriodStart: String) async throws -> SyncPeriodResponse {
        let body = try JSONEncoder().encode(["last_period_start": lastPeriodStart])
        return try await makeRequest(endpoint: "api/sync-period/", method: "POST", body: body)
    }
  
  
  
  func getInsights(lastPeriodStart: String) async throws -> SyncPeriodResponse {
      return try await makeRequest(endpoint: "api/user-insights/", method: "GET")
  }
  
  func getTrackables() async throws -> userTrackableResponse {
      return try await makeRequest(endpoint: "api/user_tracking/", method: "GET")
  }
  
  func getUserInfo() async throws -> UserInfoResponse {
      return try await makeRequest(endpoint: "api/user-info/", method: "GET")
  }
  
  func fetchCycleCalendar() async throws -> [CycleDay] {
      try await makeRequest(endpoint: "api/cycle-calendar/", method: "GET")
    
  }
  
  func getRaceGoal() async throws -> RaceGoalResponse {
    return try await makeRequest(endpoint: "api/race-goal/", method: "GET")
  }
  
  func submitRaceGoal(race: RaceGoalRequest) async throws -> SubmitRaceGoalReponse{
    let body = try JSONEncoder().encode(race)
    // Call the /api/register/ endpoint
    let response: SubmitRaceGoalReponse = try await makeRequest(
        endpoint: "api/race-goal/",
        method: "POST",
        body: body
    )
    
    return response
    
  }
  func fetchTodaysAdvice(date: Date?) async throws -> AdviceResponse {
      let endpoint: String

      if let date = date {
          let dateString = DateHelpers.formatDateForAPI(date)
          endpoint = "api/advice/today/?date=\(dateString)"
      } else {
          endpoint = "api/advice/today/"
      }

      return try await makeRequest(endpoint: endpoint, method: "GET")
  }
  

    
    // Log a run
  func logRun(run: RunEntryRequest) async throws -> [String: Any] {
    let body = try JSONEncoder().encode(run)
    guard let url = URL(string: DevConfig.baseURL + "api/log-run/") else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let token = try? await AuthManager.shared.validAccessToken() {
      //print("🔑 Attaching token: \(token.prefix(20))...")
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    } else {
      print("⚠️ No token attached to request!")
    }
    
    request.httpBody = body
    let (data, response) = try await URLSession.shared.data(for: request)
    
    if let http = response as? HTTPURLResponse, http.statusCode == 401 {
      AuthManager.shared.logout()
      throw URLError(.userAuthenticationRequired)
    }
    
    guard let http = response as? HTTPURLResponse,
          (200...299).contains(http.statusCode) else {
      let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorText])
    }
    
    return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
  }

  func login(username: String, password: String) async throws -> JWTResponse {
      let body = try JSONEncoder().encode(LoginRequest(username: username, password: password))
      // makeRequest will try validAccessToken() and get nil (no token yet) — that's fine
      let response: JWTResponse = try await makeRequest(
          endpoint: "auth/token/",
          method: "POST",
          body: body
      )
      // Store tokens immediately after login
      AuthManager.shared.storeTokens(access: response.access, refresh: response.refresh)
      return response
  }

  func register(registerBody: RegisterRequest) async throws -> RegisterResponse {
      let bodyData = try JSONEncoder().encode(registerBody)
      
      // Call the /api/register/ endpoint
      let response: RegisterResponse = try await makeRequest(
          endpoint: "api/register/",
          method: "POST",
          body: bodyData
      )
      
      return response
  }
  
  
  func logTrackable(name: String, valueNumeric: Double) async throws -> LogTrackableResponse {
      let body = try JSONEncoder().encode(
        LogTrackableRequest(name: name, value_numeric: valueNumeric, value_text: "FROM APP")
      )
      
      return try await makeRequest(
          endpoint: "api/log_trackables/",
          method: "POST",
          body: body
      )
  }
  
  
  func logSymptom(body: Data) async throws -> LogTrackableResponse {
      return try await makeRequest(
          endpoint: "api/symptoms/",
          method: "POST",
          body: body
      )
  }
}
