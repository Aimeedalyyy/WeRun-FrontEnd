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
  @StateObject private var calendarViewModel = CalendarViewModel()
  
  var body: some View {
    
      TabView {
        Tab("", systemImage: "house.fill") {
            VStack {
              if viewModel.isLoading {
                ProgressView("Loading...")
              } else
                if healthViewModel.dataFetched {
                  if let cal = viewModel.myCalendar{
                    if let advice = viewModel.myAdvice?.advice {
                      MenstrualCalendarScreen(cycleDays: cal, advice: advice, viewModel: calendarViewModel)
                        .padding(.horizontal, 12)
                    }
                  }
                  
                }
              else {
                Text("No data available")
              }
            }
            .background(Color.gray.opacity(0.05))
            .onAppear() {
              Task{
                print("testCall")
                await viewModel.testCall()
                await viewModel.getUserInfo()
                await viewModel.getUserCalendar()
                await viewModel.getTodaysAdvice()
              }
            }

        }
        Tab("", systemImage: "heart.text.square") {
          HealthInfoMainView(viewModel: healthViewModel, appViewModel: viewModel)
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
