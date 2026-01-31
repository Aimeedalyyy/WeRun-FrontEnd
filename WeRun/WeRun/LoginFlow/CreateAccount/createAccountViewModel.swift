//
//  createAccountViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//

import SwiftUI
import Foundation

class createAccountViewModel: ObservableObject{
  @Published var token: String?
  @Published var error: Error?
  @Published var username: String = ""
  @Published var password: String = ""
  @Published var email: String = ""
  
  @MainActor
  func createAccount() async {
    do {
      let user = try await APIManager.shared.register(
        username: username,
        email: email,
        password: password
      )
      
      print("User created! ID:", user.id)
      print("Username:", user.username)
    } catch {
      print("Registration failed:", error.localizedDescription)
    }
  }
  
  
}
