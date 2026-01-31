//
//  APIManager.swift
//  WeRun
//
//  Created by Aimee Daly on 03/12/2025.
//

struct DevConfig {
    static let username = "aimeedaly"
    static let password = "password"
    static let baseURL = "http://0.0.0.0:8000/"
}


import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    //let baseURL =  "http://0.0.0.0:8000/api/"  // Make sure it ends with '/'

    
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

      // 2️⃣ Inject access token dynamically from AuthManager
      if let accessToken = AuthManager.shared.accessToken {
          request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
      }

      if let body = body {
          request.httpBody = body
      }

      // 3️⃣ Perform network request
      let (data, response) = try await URLSession.shared.data(for: request)

      // 4️⃣ Cast HTTP response
      guard let http = response as? HTTPURLResponse else {
          throw URLError(.badServerResponse)
      }

      // 5️⃣ Handle 401 → attempt refresh and retry once
      print("🐞🐞🐞 HTTP Status Code:\(http.statusCode)")
    if http.statusCode == 401 {
      print("🔐 401 received, retryOnAuthFailure=\(retryOnAuthFailure)")
      
//      guard retryOnAuthFailure else {
//        AuthManager.shared.logout()
//        throw URLError(.userAuthenticationRequired)
//      }
//      
      let refreshed = await refreshAccessToken()
      
      
      guard refreshed else {
        AuthManager.shared.logout()
        throw URLError(.userAuthenticationRequired)
      }
      
      return try await makeRequest(
        endpoint: endpoint,
        method: method,
        body: body,
        retryOnAuthFailure: false
      )
    }


      // 6️⃣ Handle other HTTP errors
      guard (200...299).contains(http.statusCode) else {
          let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
          throw NSError(
              domain: "",
              code: http.statusCode,
              userInfo: [NSLocalizedDescriptionKey: errorText]
          )
      }

      // 7️⃣ Decode JSON only on success
      return try JSONDecoder().decode(T.self, from: data)
  }
  
  private func refreshAccessToken() async -> Bool {
      guard let refreshURL = URL(string: DevConfig.baseURL + "token/refresh/") else {
          return false
      }

      return await withCheckedContinuation { continuation in
          AuthManager.shared.refreshAccessToken(refreshURL: refreshURL) { success in
              continuation.resume(returning: success)
          }
      }
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
    
    // Log a run
  func logRun(run: RunEntryRequest) async throws -> [String: Any] {
    let body = try JSONEncoder().encode(run)
    guard let url = URL(string: baseURL + "api/log-run/") else { throw URLError(.badURL) }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    // Use dynamic token if available
//    if let token = token {
//      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    }
    
    request.httpBody = body
    
    let (data, response) = try await URLSession.shared.data(for: request)
    if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
      let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorText])
    }
    
    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
  }
  
  func login(username: String, password: String) async throws -> JWTResponse {
          let loginBody = LoginRequest(username: username, password: password)
          let bodyData = try JSONEncoder().encode(loginBody)

          let jwtResponse: JWTResponse = try await makeRequest(
              endpoint: "auth/token/",
              method: "POST",
              body: bodyData
          )




          return jwtResponse
      }
  
  
  func register(username: String, email: String, password: String, affiliatedUserId: Int? = nil) async throws -> RegisterResponse {
      let registerBody = RegisterRequest(
          username: username,
          email: email,
          password: password,
          affiliated_user: affiliatedUserId
      )
      
      let bodyData = try JSONEncoder().encode(registerBody)
      
      // Call the /api/register/ endpoint
      let response: RegisterResponse = try await makeRequest(
          endpoint: "api/register/",
          method: "POST",
          body: bodyData
      )
      
      return response
  }
}
