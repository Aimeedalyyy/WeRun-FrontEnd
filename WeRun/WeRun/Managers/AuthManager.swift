//
//  AuthManager.swift
//  WeRun
//
//  Created by Aimee Daly on 27/01/2026.
//


import Foundation

final class AuthManager {

    static let shared = AuthManager()
    private init() {}

    private let service        = "com.yourapp.auth"
    private let accessAccount  = "access_token"
    private let refreshAccount = "refresh_token"
    private let expiryAccount  = "token_expiry"

    // MARK: - Token Access

    var accessToken: String? {
        Keychain.load(service: service, account: accessAccount)
    }

    var refreshToken: String? {
        Keychain.load(service: service, account: refreshAccount)
    }

    var isAuthenticated: Bool {
        accessToken != nil
    }

    // MARK: - Token Expiry

    /// Decoded from the JWT payload on every save — no server call needed
    private var tokenExpiry: Date? {
        get {
            guard let raw = Keychain.load(service: service, account: expiryAccount),
                  let ts = Double(raw) else { return nil }
            return Date(timeIntervalSince1970: ts)
        }
        set {
            let raw = newValue.map { String($0.timeIntervalSince1970) }
            if let raw {
                Keychain.save(raw, service: service, account: expiryAccount)
            } else {
                Keychain.delete(service: service, account: expiryAccount)
            }
        }
    }

    /// Returns true if the access token has more than 60 seconds left
    var isAccessTokenValid: Bool {
        guard let expiry = tokenExpiry else { return false }
        return Date().addingTimeInterval(60) < expiry
    }

    // MARK: - Token Storage

    func storeTokens(access: String, refresh: String) {
        Keychain.save(access, service: service, account: accessAccount)
        Keychain.save(refresh, service: service, account: refreshAccount)
        tokenExpiry = decodeExpiry(from: access)   // ← decode & persist expiry
    }

    func logout() {
        Keychain.delete(service: service, account: accessAccount)
        Keychain.delete(service: service, account: refreshAccount)
        Keychain.delete(service: service, account: expiryAccount)
        refreshTask = nil
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }

    // MARK: - Authorization Header

    func authorize(_ request: inout URLRequest) {
        guard let token = accessToken else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    // MARK: - Valid Token (auto-refreshes if needed)

    /// Call this before every authenticated request instead of accessToken directly.
    /// Handles refresh automatically and deduplicates concurrent refresh calls.
  func validAccessToken() async throws -> String {
    
    //print("🔑 isAccessTokenValid: \(isAccessTokenValid)")
    //print("🔑 tokenExpiry: \(String(describing: tokenExpiry))")
    //print("🔑 accessToken exists: \(accessToken != nil)")
    
    // Fast path — token is still fresh
    if isAccessTokenValid, let token = accessToken {
      return token
    }
    // If a refresh is already in-flight, await that task instead of firing another
    if let existing = refreshTask {
      return try await existing.value
    }
    let task = Task<String, Error> {
      defer { self.refreshTask = nil }
      //print("🔑 Token expired, lets call performRefresh()")
      return try await performRefresh()
    }
    refreshTask = task
    return try await task.value
  }

    // MARK: - Private

    /// Held while a refresh is in-flight so concurrent callers share one network request
    private var refreshTask: Task<String, Error>?

    private func performRefresh() async throws -> String {
        //print("🔑 Refreshing access token...")
        guard let refresh = refreshToken else {
            logout()
            throw AuthError.noRefreshToken
        }
        //print("🔑🔄 Refresh token exists: \(refresh.prefix(20))...")

        // ---- build request ----
        guard let url = URL(string:  DevConfig.baseURL +  "auth/token/refresh/") else {
            throw AuthError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["refresh": refresh])

        // ---- fire request ----
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            // Refresh token is dead — force the user back to login
          //print("🔑🔄 Refresh failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")

            logout()
            throw AuthError.refreshFailed
        }
      //print("🔑🔄 Refresh succeeded!")

        // ---- parse & store ----
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let newAccess = json["access"] as? String else {
            logout()
            throw AuthError.refreshFailed
        }

        let newRefresh = json["refresh"] as? String ?? refresh  // SimpleJWT may not rotate it
        storeTokens(access: newAccess, refresh: newRefresh)
        return newAccess
    }

    /// Decodes the `exp` claim from a JWT without any third-party library
    private func decodeExpiry(from jwt: String) -> Date? {
        let parts = jwt.split(separator: ".").map(String.init)
        guard parts.count == 3 else { return nil }

        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }   // pad to valid base64

        guard let data    = Data(base64Encoded: base64),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp     = payload["exp"] as? TimeInterval else { return nil }

        return Date(timeIntervalSince1970: exp)
    }
}

// MARK: - Errors

enum AuthError: LocalizedError {
    case noRefreshToken
    case refreshFailed
    case badURL

    var errorDescription: String? {
        switch self {
        case .noRefreshToken: return "No refresh token available."
        case .refreshFailed:  return "Session expired. Please log in again."
        case .badURL:         return "Invalid refresh URL."
        }
    }
}

// MARK: - Notification

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
