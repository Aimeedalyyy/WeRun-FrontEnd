//
//  loginViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//

import Foundation


class loginViewModel: ObservableObject{
  @Published var token: String?
  @Published var error: Error?
  @Published var isLoading = false
  @Published var username: String = ""
  @Published var password: String = ""
  
  
  func login() async {
    Task {
        do {
            let accessToken = try await APIManager.shared.login(
                username: "aimeedaly",
                password: "password"
            )
          
            print("Logged in! Token:", accessToken)
        } catch {
            print("Login failed:", error.localizedDescription)
        }
    }
  }
}
