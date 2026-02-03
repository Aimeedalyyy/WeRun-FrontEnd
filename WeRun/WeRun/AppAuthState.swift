//
//  AppAuthState.swift
//  WeRun
//
//  Created by Aimee Daly on 29/01/2026.
//

import Foundation

@MainActor
final class AppAuthState: ObservableObject {
  @Published var isAuthenticated: Bool = false



    func logout() {
        AuthManager.shared.logout()
        isAuthenticated = false
        print("🐞 Logged Out \(isAuthenticated)")
    }

    func loginSucceeded() {
        isAuthenticated = true
    }
}
