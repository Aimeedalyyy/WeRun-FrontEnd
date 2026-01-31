//
//  AuthViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//


import SwiftUI

struct TokenPair: Decodable {
    let access: String
    let refresh: String
}

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var error: String?
    @Published var isLoggedIn = false

    @Published var username = ""
    @Published var email = ""
    @Published var password = ""

    enum AuthMode {
        case login
        case register
    }

    @Published var mode: AuthMode = .login

    func authenticate() async {
        isLoading = true
        error = nil

        do {
            switch mode {

            case .login:
                let tokens = try await APIManager.shared.login(
                    username: username,
                    password: password
                )

                AuthManager.shared.storeTokens(
                    access: tokens.access,
                    refresh: tokens.refresh
                )

            case .register:
                _ = try await APIManager.shared.register(
                    username: username,
                    email: email,
                    password: password
                )

                let tokens = try await APIManager.shared.login(
                    username: username,
                    password: password
                )

                AuthManager.shared.storeTokens(
                    access: tokens.access,
                    refresh: tokens.refresh
                )
            }

            isLoggedIn = true

        } catch {
            self.error = error.localizedDescription
            print("Auth failed:", error)
        }

        isLoading = false
    }
}
