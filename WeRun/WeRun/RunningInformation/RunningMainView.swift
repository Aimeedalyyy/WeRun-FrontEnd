//
//  RunningMainView.swift
//  WeRun
//
//  Created by Aimee Daly on 26/11/2025.
//

import SwiftUI

struct RunningMainView: View {
  @StateObject private var workoutManager = WorkoutManager()
  @StateObject var viewModel: RunningViewModel

  
  var body: some View {
      NavigationView {
          ZStack {
              
              VStack(spacing: 30) {
                if !viewModel.isLocationAuthorized{
                      authorizeView
                } else if viewModel.showHistory {
                      workoutHistoryView
                  } else if !workoutManager.isRunning {
                      startView
                  } else {
                      workoutView
                  }
              }
              .padding()
          }
          .navigationTitle(viewModel.showHistory ? "Workout History" : "Running Tracker")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            if viewModel.isLocationAuthorized && !workoutManager.isRunning {
                  ToolbarItem(placement: .navigationBarTrailing) {
                      Button(action: {
                        viewModel.showHistory.toggle()
                        if viewModel.showHistory {
                            HealthKitManager.shared.fetchAllRunningWorkouts { _ in }
                          }
                      }) {
                        Image(systemName: viewModel.showHistory ? "play.circle" : "clock.arrow.circlepath")
                          .foregroundColor(.accentgreen)
                      }
                  }
              }
          }
          .alert("Running Tracker", isPresented: $viewModel.showingAlert) {
              Button("OK", role: .cancel) { }
          } message: {
            Text(viewModel.alertMessage)
          }
          .sheet(isPresented: $viewModel.showDatePicker) {
              datePickerSheet
          }
      }
  }
  
  // MARK: - Authorization View
  private var authorizeView: some View {
      VStack(spacing: 20) {
          Image(systemName: "figure.run")
              .font(.system(size: 80))
              .foregroundColor(.accentgreen)
          
          Text("Track Your Runs")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(.accentgreen)
          
          Text("This app needs access to HealthKit and your location to track your running workouts.")
              .font(.body)
              .foregroundColor(.accentgreen)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          
          Button(action: authorize) {
              Text("Authorize")
                  .font(.headline)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.accentgreen)
                  .cornerRadius(15)
          }
          .padding(.horizontal)
      }
  }
  
  // MARK: - Start View
  private var startView: some View {
      VStack(spacing: 40) {
          Image(systemName: "figure.run.circle.fill")
              .font(.system(size: 120))
              .foregroundColor(.accentgreen)
          
          Text("Ready to Run?")
              .font(.largeTitle)
              .fontWeight(.bold)
              .foregroundColor(.accentgreen)
          
          Button(action: {
              workoutManager.startWorkout()
          }) {
              Text("Start Workout")
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(.white)
                  .frame(width: 200, height: 60)
                  .background(Color.accentgreen)
                  .cornerRadius(30)
                  .shadow(radius: 10)
          }
      }
  }
  
  // MARK: - Workout History View
  private var workoutHistoryView: some View {
      VStack(spacing: 20) {
          Button(action: {
            viewModel.showDatePicker = true
          }) {
              HStack {
                  Image(systemName: "calendar")
                Text("Select Date: \(viewModel.selectedDate, style: .date)")
              }
              .foregroundColor(.accentgreen)
              .padding()
              .background(Color.white.opacity(0.2))
              .cornerRadius(10)
          }
          
          if HealthKitManager.shared.workoutHistory.isEmpty {
              VStack(spacing: 20) {
                  Image(systemName: "figure.run")
                      .font(.system(size: 60))
                      .foregroundColor(.accentgreen.opacity(0.6))
                  Text("No workouts found")
                      .font(.title3)
                      .foregroundColor(.accentgreen.opacity(0.8))
              }
              .frame(maxHeight: .infinity)
          } else {
              ScrollView {
                  VStack(spacing: 15) {
                      ForEach(HealthKitManager.shared.workoutHistory, id: \.uuid) { workout in
                          WorkoutCard(workout: workout)
                      }
                  }
              }
          }
      }
  }
  
  // MARK: - Date Picker Sheet
  private var datePickerSheet: some View {
      NavigationView {
          VStack {
            DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                  .datePickerStyle(.graphical)
                  .padding()
              
              Spacer()
          }
          .navigationTitle("Select Date")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                  Button("Done") {
                    viewModel.showDatePicker = false
                    HealthKitManager.shared.fetchWorkouts(for: viewModel.selectedDate) { workouts in
                      HealthKitManager.shared.workoutHistory = workouts
                      }
                  }
              }
              ToolbarItem(placement: .navigationBarLeading) {
                  Button("All Workouts") {
                    viewModel.showDatePicker = false
                    HealthKitManager.shared.fetchAllRunningWorkouts { _ in }
                  }
              }
          }
      }
  }
  
  // MARK: - Workout View
  private var workoutView: some View {
      VStack(spacing: 30) {
          // Stats Grid
          VStack(spacing: 20) {
              HStack(spacing: 20) {
                  StatCard(
                      title: "Distance",
                      value: String(format: "%.2f", workoutManager.distance / 1000),
                      unit: "km",
                      icon: "location.fill"
                  )
                  
                  StatCard(
                      title: "Duration",
                      value: formatTime(workoutManager.duration),
                      unit: "",
                      icon: "clock.fill"
                  )
              }
              
              HStack(spacing: 20) {
                  StatCard(
                      title: "Pace",
                      value: String(format: "%.1f", workoutManager.pace),
                      unit: "min/km",
                      icon: "speedometer"
                  )
                  
                  StatCard(
                      title: "Calories",
                      value: String(format: "%.0f", workoutManager.calories),
                      unit: "kcal",
                      icon: "flame.fill"
                  )
              }
          }
          
          Spacer()
          
          // Control Buttons
          HStack(spacing: 30) {
              if workoutManager.isPaused {
                  Button(action: {
                      workoutManager.resumeWorkout()
                  }) {
                      Image(systemName: "play.circle.fill")
                          .font(.system(size: 70))
                          .foregroundColor(.green)
                  }
              } else {
                  Button(action: {
                      workoutManager.pauseWorkout()
                  }) {
                      Image(systemName: "pause.circle.fill")
                          .font(.system(size: 70))
                          .foregroundColor(.yellow)
                  }
              }
              
              Button(action: finishWorkout) {
                  Image(systemName: "stop.circle.fill")
                      .font(.system(size: 70))
                      .foregroundColor(.red)
              }
          }
      }
  }
  
  // MARK: - Helper Functions
  private func authorize() {
      // Request location permission first
      print("authorising location details")
      if workoutManager.requestLocationPermission(){
        viewModel.isLocationAuthorized = true
      }
  }
  
  private func finishWorkout() {
      let workoutData = workoutManager.stopWorkout()
      
    HealthKitManager.shared.saveWorkout(
          distance: workoutData.distance,
          duration: workoutData.duration,
          calories: workoutData.calories,
          startDate: workoutData.startDate
      ) { success in
          if success {
            viewModel.alertMessage = "Workout saved to Apple Health!"
          } else {
            viewModel.alertMessage = "Failed to save workout to Apple Health."
          }
          viewModel.showingAlert = true
      }
  }
  
  private func formatTime(_ timeInterval: TimeInterval) -> String {
      let hours = Int(timeInterval) / 3600
      let minutes = Int(timeInterval) / 60 % 60
      let seconds = Int(timeInterval) % 60
      
      if hours > 0 {
          return String(format: "%d:%02d:%02d", hours, minutes, seconds)
      } else {
          return String(format: "%d:%02d", minutes, seconds)
      }
  }
}
#Preview {
  RunningMainView(viewModel: RunningViewModel())
}
