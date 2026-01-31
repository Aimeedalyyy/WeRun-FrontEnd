//
//  ContentView.swift
//  WeRun
//
//  Created by Aimee Daly on 22/11/2025.
//
//


import SwiftUI
import Foundation

struct ContentView: View {
  @EnvironmentObject var authState: AppAuthState
  
  var body: some View {
    NavigationStack {
      ZStack {
        if authState.isAuthenticated {
          HomeView()
            .transition(.move(edge: .trailing).combined(with: .opacity))
            .id(authState.isAuthenticated)
        } else {
          LoginRegisterView()
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
      }
    }
  }
}



    
#Preview {
  NavigationStack {
    ContentView()
  }
}

