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
    @Published var trackables: [LogTrackableRequest] = []
    @Published var symptoms: [String] = []
    @Published var trackableSet: Set<TrackableItem> = []
    @Published var selectedSymptoms: Set<String> = []

  

    enum AuthMode {
        case login
        case register
    }

    @Published var mode: AuthMode = .login
  
  @MainActor
  func createAccount() async {
    //map trackables into an array to send to the api
    var trackablesRequest: [LogTrackableRequest] {
      trackableSet.map {
            LogTrackableRequest(
                name: $0.name,
                value_numeric: $0.value_numeric ?? 0.0,
                value_text: $0.value_text
            )
        }
    }
    //map symptoms into an array to send to the api
    var symptomsArray: [String] {
        Array(selectedSymptoms)
    }
    
  
    
    do {
      let requestBody = RegisterRequest(username: username, email: email, password: password, affiliated_user: nil,last_period_sync: nil, last_period_start: nil, last_period_end: nil, trackables: trackablesRequest, symptoms: symptomsArray)
      
      print("🐞🐞 Request Body:\(requestBody)🐞🐞")
      
      let user = try await APIManager.shared.register(registerBody: requestBody)
                                                    
      
      
      print("User created! ID:", user.id)
      print("Username:", user.username)
    } catch {
      print("Registration failed:", error.localizedDescription)
    }
  }


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
                  registerBody: RegisterRequest(username: username, email: email, password: password, affiliated_user: nil, last_period_sync: nil, last_period_start: nil, last_period_end: nil, trackables: trackables, symptoms: symptoms)
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
