//
//  RunningMainView.swift
//  WeRun
//
//  Created by Aimee Daly on 26/11/2025.
//

//@State private var showMotivationInput = false
//@State private var showWorkoutSummary = false
//@State private var showStopConfirmation = false

import SwiftUI

struct RunningMainView: View {
    @StateObject var viewModel: RunningViewModel
        
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    if !viewModel.isLocationAuthorized {
                        authorizeView
                    } else if viewModel.showHistory {
                        workoutHistoryView
                    } else if viewModel.showWorkoutSummary {
                        workoutSummaryView
                    } else if !WorkoutManager.shared.isRunning {
                        startView
                    } else {
                      WorkoutView(viewModel: viewModel)
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.showHistory ? "Workout History" : viewModel.showWorkoutSummary ? "Workout Summary" : "Running Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              if viewModel.isLocationAuthorized && !WorkoutManager.shared.isRunning && !viewModel.showWorkoutSummary {
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
            .sheet(isPresented: $viewModel.showMotivationInput) {
                motivationInputSheet
            }
            .confirmationDialog("Are you sure you want to finish the workout?", isPresented: $viewModel.showStopConfirmation, titleVisibility: .visible) {
                Button("Finish Workout", role: .destructive) {
                  viewModel.finishWorkout()
                }
                Button("Cancel", role: .cancel) { }
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
              viewModel.showMotivationInput = true
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
    
    // MARK: - Motivation Input Sheet
    private var motivationInputSheet: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("How motivated are you feeling?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentgreen)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                VStack(spacing: 10) {
                  Text("\(viewModel.motivationLevel)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.accentgreen)
                    
                  Text(motivationDescription(for: viewModel.motivationLevel))
                        .font(.subheadline)
                        .foregroundColor(.accentgreen.opacity(0.8))
                }
                
                Slider(value: Binding(
                  get: { Double(viewModel.motivationLevel) },
                  set: { viewModel.motivationLevel = Int($0) }
                ), in: 1...10, step: 1)
                    .accentColor(.accentgreen)
                    .padding(.horizontal, 40)
                
                HStack {
                    Text("Low")
                        .font(.caption)
                        .foregroundColor(.accentgreen.opacity(0.6))
                    Spacer()
                    Text("High")
                        .font(.caption)
                        .foregroundColor(.accentgreen.opacity(0.6))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                  viewModel.showMotivationInput = false
                    WorkoutManager.shared.startWorkout()
                }) {
                    Text("Start Running")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentgreen)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Pre-Run Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                      viewModel.showMotivationInput = false
                    }
                }
            }
        }
    }
    
    // MARK: - Workout Summary View
    private var workoutSummaryView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentgreen)
            
            Text("Workout Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentgreen)
            
          if let data = viewModel.completedWorkoutData {
                VStack(spacing: 20) {
                    SummaryRow(
                        icon: "location.fill",
                        title: "Distance",
                        value: String(format: "%.2f km", data.distance / 1000)
                    )
                    
                    SummaryRow(
                        icon: "speedometer",
                        title: "Average Pace",
                        value: String(format: "%.1f min/km", data.pace)
                    )
                    
                    SummaryRow(
                        icon: "clock.fill",
                        title: "Duration",
                        value: formatTime(data.duration)
                    )
                    
                    SummaryRow(
                        icon: "flame.fill",
                        title: "Calories",
                        value: String(format: "%.0f kcal", data.calories)
                    )
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
            }
            
            Spacer()
            
            Button(action: {
              viewModel.showWorkoutSummary = false
                viewModel.completedWorkoutData = nil
            }) {
                Text("Done")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentgreen)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .padding()
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
                .onAppear {
                    HealthKitManager.shared.fetchAllRunningWorkouts { _ in }
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
//    private var workoutView: some View {
//        VStack(spacing: 30) {
//            // Stats Grid
//            VStack(spacing: 20) {
//                HStack(spacing: 20) {
//                    StatCard(
//                        title: "Distance",
//                        value: String(format: "%.2f", WorkoutManager.shared.distance / 1000),
//                        unit: "km",
//                        icon: "location.fill"
//                    )
//                    
//                    StatCard(
//                        title: "Duration",
//                        value: formatTime(WorkoutManager.shared.duration),
//                        unit: "",
//                        icon: "clock.fill"
//                    )
//                }
//                
//                HStack(spacing: 20) {
//                    StatCard(
//                        title: "Pace",
//                        value: String(format: "%.1f", WorkoutManager.shared.pace),
//                        unit: "min/km",
//                        icon: "speedometer"
//                    )
//                    
//                    StatCard(
//                        title: "Calories",
//                        value: String(format: "%.0f", WorkoutManager.shared.calories),
//                        unit: "kcal",
//                        icon: "flame.fill"
//                    )
//                }
//            }
//            
//            Spacer()
//            
//            // Control Buttons
//            HStack(spacing: 30) {
//                if WorkoutManager.shared.isPaused {
//                    Button(action: {
//                      WorkoutManager.shared.resumeWorkout()
//                    }) {
//                        Image(systemName: "play.circle.fill")
//                            .font(.system(size: 70))
//                            .foregroundColor(.green)
//                    }
//                } else {
//                    Button(action: {
//                      WorkoutManager.shared.pauseWorkout()
//                    }) {
//                        Image(systemName: "pause.circle.fill")
//                            .font(.system(size: 70))
//                            .foregroundColor(.yellow)
//                    }
//                }
//                
//                Button(action: {
//                  viewModel.showStopConfirmation = true
//                }) {
//                    Image(systemName: "stop.circle.fill")
//                        .font(.system(size: 70))
//                        .foregroundColor(.red)
//                }
//            }
//        }
//    }
    
    // MARK: - Helper Functions
    private func authorize() {
        print("authorising location details")
        if WorkoutManager.shared.requestLocationPermission() {
            viewModel.isLocationAuthorized = true
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
    
    private func motivationDescription(for level: Int) -> String {
        switch level {
        case 1...3: return "Taking it easy today"
        case 4...6: return "Feeling okay"
        case 7...8: return "Ready to push!"
        case 9...10: return "Feeling unstoppable!"
        default: return ""
        }
    }
}

// MARK: - Summary Row Component
struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentgreen)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.accentgreen)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.accentgreen)
        }
        .padding(.horizontal)
    }
}

#Preview {
    RunningMainView(viewModel: RunningViewModel())
}
