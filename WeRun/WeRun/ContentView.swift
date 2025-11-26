//
//  ContentView.swift
//  WeRun
//
//  Created by Aimee Daly on 22/11/2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
  @StateObject private var viewModel = AppViewModel()
  @StateObject private var healthViewModel = HealthInfoViewModel()
  @StateObject private var runningViewModel = RunningViewModel()
  
  var body: some View {
    NavigationStack {
      TabView {
        Tab("", systemImage: "house.fill") {
          NavigationStack {
            VStack {
              if viewModel.isLoading {
                ProgressView("Loading...")
              } else if viewModel.tests.test_number == 1 {
                VStack {
                  Text("Return from server !")
                  Text(viewModel.tests.test_name)
                  Text(String(viewModel.tests.test_number))
                }
              } else {
                Text("No data available")
              }
            }
            .background(Color.gray.opacity(0.05))
            .task {
              await viewModel.testCall()
            }
            
          }
          
        }
        Tab("", systemImage: "heart.text.square") {
          NavigationStack {
            HealthInfoMainView(viewModel: healthViewModel)
              .background(Color.gray.opacity(0.05))
          }
          
        }
        Tab("", systemImage: "chart.line.text.clipboard") {
          NavigationStack {
            EmptyView()
              .background(Color.gray.opacity(0.05))
            
          }
        }
        Tab("", systemImage: "figure.run.square.stack") {
          NavigationStack {
            RunningMainView(viewModel: runningViewModel)
              .background(Color.gray.opacity(0.05))
          }
        }
        Tab("", systemImage: "person.crop.circle.fill") {
          NavigationStack {
            EmptyView()
              .background(Color.gray.opacity(0.05))
          }
        }
      }
      
    }
    .tabViewStyle(
      backgroundColor: .accentPurple,
      itemColor: .backgroundGrey.opacity(0.4),
      badgeColor: .white,
      selectedItemColor: .backgroundGrey
    )
  }
}
      
      
      
      


#Preview {
  NavigationStack {
    ContentView()
  }
}

