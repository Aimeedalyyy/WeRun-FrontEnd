//
//  APIManager.swift
//  WeRun
//
//  Created by Aimee Daly on 03/12/2025.
//

struct DevConfig {
    static let username = "aimeedaly"
    static let password = "password"
    static let token = "09c8a705437b24cbb8edcec32fccb6d0ac9c7cbf"
    static let baseURL = "http://0.0.0.0:8000/api/"
}


import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    let baseURL =  "http://0.0.0.0:8000/api/"  // Make sure it ends with '/'
    var token: String? // Set after login
    
    // MARK: - Helper Request Function
  private func makeRequest<T: Codable>( endpoint: String, method: String,body: Data? = nil) async throws -> T {

      guard let url = URL(string: DevConfig.baseURL + endpoint) else {
          throw URLError(.badURL)
      }

      var request = URLRequest(url: url)
      request.httpMethod = method
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("Token \(DevConfig.token)", forHTTPHeaderField: "Authorization")

      if let body = body {
          request.httpBody = body
      }

      let (data, response) = try await URLSession.shared.data(for: request)

      if let httpResponse = response as? HTTPURLResponse,
         !(200...299).contains(httpResponse.statusCode) {

          let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
          throw NSError(
              domain: "",
              code: httpResponse.statusCode,
              userInfo: [NSLocalizedDescriptionKey: errorText]
          )
      }

      return try JSONDecoder().decode(T.self, from: data)
  }
    
    // MARK: - Endpoints
    
    // Test API
    func testAPI(lastPeriodStart: String) async throws -> TestResponse {
      let body = try JSONEncoder().encode(["last_period_start": lastPeriodStart])
      return try await makeRequest(endpoint: "test/", method: "POST", body: body)
    }
    
    // Analysis: all phases comparison
    func getAnalysis() async throws -> PhaseComparisonResponse {
        return try await makeRequest(endpoint: "all-phases-comparison/", method: "GET")
    }
    
    // Phase comparison by phase name
    func getPhaseComparison(for phase: String) async throws -> PhaseStats {
        return try await makeRequest(endpoint: "phase-comparison/\(phase)/", method: "GET")
    }
    
    // Sync period
    func syncPeriod(lastPeriodStart: String) async throws -> SyncPeriodResponse {
        let body = try JSONEncoder().encode(["last_period_start": lastPeriodStart])
        return try await makeRequest(endpoint: "sync-period/", method: "POST", body: body)
    }
  
  func getInsights(lastPeriodStart: String) async throws -> SyncPeriodResponse {
      return try await makeRequest(endpoint: "user-insights/", method: "GET")
  }
    
    // Log a run
  func logRun(run: RunEntryRequest) async throws -> [String: Any] {
        let body = try JSONEncoder().encode(run)
        guard let url = URL(string: baseURL + "log-run/") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(DevConfig.token)", forHTTPHeaderField: "Authorization")
      
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
    }
}
