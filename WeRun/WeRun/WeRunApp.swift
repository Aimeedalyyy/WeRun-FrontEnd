//
//  WeRunApp.swift
//  WeRun
//
//  Created by Aimee Daly on 22/11/2025.
//

import SwiftUI

@main
struct WeRunApp: App {
  @StateObject private var authState = AppAuthState()

    var body: some Scene {
      WindowGroup {
        ContentView()
            .environmentObject(authState)

      }
    }
}
