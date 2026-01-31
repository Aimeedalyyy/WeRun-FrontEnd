//
//  AppAuthState.swift
//  WeRun
//
//  Created by Aimee Daly on 29/01/2026.
//

import Foundation

@MainActor
final class AppAuthState: ObservableObject {
    @Published var isAuthenticated: Bool = AuthManager.shared.isAuthenticated

    func logout() {
        AuthManager.shared.logout()
        isAuthenticated = false
        print("🐞 Logged Out")
    }

    func loginSucceeded() {
        isAuthenticated = true
    }
}
