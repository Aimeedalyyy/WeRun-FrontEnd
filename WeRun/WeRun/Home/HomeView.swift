//
//  HomeView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//

import SwiftUI
import Foundation

struct HomeView: View {
  @StateObject private var viewModel = AppViewModel()
  @StateObject private var healthViewModel = HealthInfoViewModel()
  @StateObject private var runningViewModel = RunningViewModel()
  @StateObject private var analysisViewModel = AnalysisViewModel()
  @StateObject private var authViewModel = AuthViewModel()
  
  var body: some View {
    
      TabView {
        Tab("", systemImage: "house.fill") {
            VStack {
              if viewModel.isLoading {
                ProgressView("Loading...")
              } else if let test = viewModel.tests {
                let phase = CyclePhase.from(test.calculated_phase)
                ScrollView{
                  MenstrualCalendarScreen(menstrualSample: healthViewModel.menstrualData, today: CycleDay(dayofCycle: 1, date: Date(), phase: phase, workoutType: ""), dayOfCycle: test.cycle_day)
                  
                }
                .padding(.horizontal, 8)
              } else {
                Text("No data available")
              }
            }
            .background(Color.gray.opacity(0.05))
            .onAppear() {
              Task{
                await viewModel.testCall()

              }
            }

        }
        Tab("", systemImage: "heart.text.square") {
            HealthInfoMainView(viewModel: healthViewModel)
              .background(Color.gray.opacity(0.05))
          
        }
        Tab("", systemImage: "chart.line.text.clipboard") {
            AnalysisMainView(viewModel: analysisViewModel)
              .background(Color.gray.opacity(0.05))
            
          
        }
        Tab("", systemImage: "figure.run.square.stack") {
            RunningMainView(viewModel: runningViewModel)
              .background(Color.gray.opacity(0.05))
          
        }
        Tab("", systemImage: "person.crop.circle.fill") {
          UserSettingsView(viewModel: authViewModel)
              .background(Color.gray.opacity(0.05))
        }
      }
      
    
    .tabViewStyle(
      backgroundColor: .accentPurple,
      itemColor: .backgroundGrey.opacity(0.4),
      badgeColor: .white,
      selectedItemColor: .backgroundGrey
    )
    .navigationBarBackButtonHidden(true)
  }
}
      
      
      
      


#Preview {
  NavigationStack {
    HomeView()
  }
}
