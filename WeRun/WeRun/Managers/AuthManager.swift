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

    private let service = "com.yourapp.auth"
    private let accessAccount = "access_token"
    private let refreshAccount = "refresh_token"

    // MARK: - Token Access

    var accessToken: String? {
        Keychain.load(service: service, account: accessAccount)
    }

    var refreshToken: String? {
        Keychain.load(service: service, account: refreshAccount)
    }

    var isAuthenticated: Bool {
      print("🐞🐞 access token: \(accessToken ?? nil) 🐞🐞")
        return accessToken != nil
    }

    // MARK: - Token Storage

    func storeTokens(access: String, refresh: String) {
        Keychain.save(access, service: service, account: accessAccount)
        Keychain.save(refresh, service: service, account: refreshAccount)
    }

    func logout() {
        Keychain.delete(service: service, account: accessAccount)
        Keychain.delete(service: service, account: refreshAccount)
    }

    // MARK: - Authorization Header

    func authorize(_ request: inout URLRequest) {
        guard let token = accessToken else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    // MARK: - Token Refresh

    func refreshAccessToken(
        refreshURL: URL,
        completion: @escaping (Bool) -> Void
    ) {
        guard let refreshToken = refreshToken else {
            completion(false)
            return
        }

        var request = URLRequest(url: refreshURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let newAccess = json["access"] as? String
            else {
                completion(false)
                return
            }

            // SimpleJWT may or may not return a new refresh token
            if let newRefresh = json["refresh"] as? String {
                self.storeTokens(access: newAccess, refresh: newRefresh)
            } else if let existingRefresh = self.refreshToken {
                self.storeTokens(access: newAccess, refresh: existingRefresh)
            }

            completion(true)
        }.resume()
    }
}
