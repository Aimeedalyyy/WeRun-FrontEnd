//
//  MenstrualCalendarScreen.swift
//  WeRun
//
//  Created by Aimee Daly on 02/03/2026.
//

import SwiftUI
import Foundation


struct MenstrualCalendarScreen: View {
  @State private var selectedDay: CycleDay?
  @State private var selectedIndex: Int
  @State var fullcycle: [CycleDay]
  @State private var showMenstrualCalendar = false
  @State var advice: [Advice]
  @ObservedObject var viewModel: CalendarViewModel
  @ObservedObject var raceViewModel: RaceViewModel
  @ObservedObject var appViewModel: AppViewModel
  
  
  
  init(cycleDays: [CycleDay], advice: [Advice], viewModel: CalendarViewModel, raceViewModel: RaceViewModel, appViewModel: AppViewModel) {
    let todayIndex = cycleDays.firstIndex(where: {
      Calendar.current.isDateInToday($0.date)
    }) ?? 0
    
    self._fullcycle = State(initialValue: cycleDays)
    self._selectedIndex = State(initialValue: todayIndex)
    self._advice = State(initialValue: advice)
    self.viewModel = viewModel
    self.raceViewModel = raceViewModel
    self.appViewModel = appViewModel
  }
  
  var body: some View {
    ScrollView{
      VStack {
        
        Toggle(isOn: $showMenstrualCalendar) {
          Text("Menstrual Calendar")
            .font(.headline)
            .foregroundColor(.accentPurple)
        }
        .tint(.accentPurple)
        
        if showMenstrualCalendar {
          CalendarGridView(
            days: fullcycle,
            selectedIndex: $selectedIndex,
            onDayTapped: { day in
              Task {
                await viewModel.getDaysAdvice(date: day.date)
              }
            }
          )
        }
        
      }
      GeometryReader { geo in
          TabView(selection: $selectedIndex) {
              ForEach(Array(fullcycle.enumerated()), id: \.element.id) { index, day in
                VStack{
                  DayDetailPage(
                      day: day,
                      advice: viewModel.adviceByDate[Calendar.current.startOfDay(for: day.date)]
                  )
                }
                .tag(index)
              }
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
          .frame(height: geo.size.height)
      }
      .frame(height: UIScreen.main.bounds.height * 0.50)
      .onChange(of: selectedIndex) { oldValue, newValue in
          let day = fullcycle[newValue]

          Task {
              await viewModel.getDaysAdvice(date: day.date)
          }
      }
      PhaseDotsView(
        currentPhase: fullcycle[selectedIndex].phase
      )
      
      if let raceGoal = raceViewModel.raceGoal {
        if raceGoal.has_race_goal {
          RaceGoalCapsule(race: raceGoal)
        }
        else
        {
          addRaceGoal
        }
      }

    }
    .navigationDestination(isPresented: $viewModel.showAddRaceGoalModal){
      SetRaceGoalView(viewModel: raceViewModel)
      .background(Color.gray.opacity(0.05))
  }
    .refreshable {
      print("🐞🐞 Pull to refresh !")
      await raceViewModel.getRaceGoal()
      await viewModel.getUserCalendar()
    }
    .onAppear(){
      Task{
        await viewModel.getDaysAdvice(date: Date())
        //await viewModel.getUserCalendar()
        await raceViewModel.getRaceGoal()
      }
    }
    .onChange(of: selectedIndex) { _, newIndex in
        Task {
            await viewModel.getDaysAdvice(date: fullcycle[newIndex].date)

            if newIndex + 1 < fullcycle.count {
                await viewModel.getDaysAdvice(date: fullcycle[newIndex + 1].date)
            }

            if newIndex > 0 {
                await viewModel.getDaysAdvice(date: fullcycle[newIndex - 1].date)
            }
        }
    }
  }
  
  struct CycleStatusCard: View {
    let currentDay: CycleDay
    
    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text("Today")
          .font(.caption)
          .foregroundStyle(.secondary)
        
        Text(currentDay.phase.rawValue.capitalized + " Phase")
          .font(.title3)
          .fontWeight(.semibold)
        
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(currentDay.phase.color.opacity(0.25))
      .clipShape(RoundedRectangle(cornerRadius: 28))
      .overlay(
        RoundedRectangle(cornerRadius: 28)
          .stroke(currentDay.phase.color, lineWidth: 2)
      )
    }
  }
  
  
  struct CalendarGridView: View {
    let days: [CycleDay]
    @Binding var selectedIndex: Int
    var onDayTapped: (CycleDay) -> Void
    
    private let columns = Array(
      repeating: GridItem(.flexible()),
      count: 7
    )
    
    var body: some View {
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
          CalendarDayCell(
            day: day,
            isSelected: index == selectedIndex
          )
          .onTapGesture {
            selectedIndex = index
            onDayTapped(day)
          }
        }
      }
    }
  }
  
  struct CalendarDayCell: View {
    let day: CycleDay
    let isSelected: Bool
    
    var isToday: Bool {
      Calendar.current.isDateInToday(day.date)
    }
    
    var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(day.phase.color.opacity(0.25))
        
        RoundedRectangle(cornerRadius: 10)
          .stroke(
            isSelected
            ? day.phase.color
            : isToday
            ? day.phase.color.opacity(0.6)
            : .clear,
            lineWidth: isSelected ? 3 : 2
          )
        
        VStack(spacing: 4) {
          Text(String(day.day_of_cycle))
            .font(.caption)
          
          if day.workout?.session_type != "rest" {
            Circle()
              .frame(width: 4, height: 4)
          }
        }
        .padding(6)
      }
      .frame(height: 44)
    }
    
    private var dateNumber: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "d"
      return formatter.string(from: day.date)
    }
  }
  
  struct AdviceCardRow: View {
    let item: Advice
    let phase: CyclePhase
    
    var body: some View {
      VStack(alignment: .leading, spacing: 6) {
        HStack(alignment: .top) {
          Text(item.title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .fixedSize(horizontal: false, vertical: true)
          Spacer()
          Text(item.category.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(phase.color.opacity(0.15))
            .foregroundColor(phase.color)
            .clipShape(Capsule())
        }
        Text(item.body)
          .font(.footnote)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(12)
      .background(Color(.secondarySystemBackground))
      .cornerRadius(12)
    }
  }
  
  struct PhaseDotsView: View {
    let currentPhase: CyclePhase
    
    var body: some View {
      HStack(spacing: 12) {
        ForEach(CyclePhase.allCases, id: \.self) { phase in
          Circle()
            .fill(phase.color)
            .frame(
              width: phase == currentPhase ? 14 : 8,
              height: phase == currentPhase ? 14 : 8
            )
            .animation(.easeInOut(duration: 0.2), value: currentPhase)
        }
      }
    }
  }
  
  struct DayDetailPage: View {
      let day: CycleDay
      let advice: AdviceResponse?

      var body: some View {
          VStack(alignment: .leading, spacing: 12) {

              VStack(spacing: 4) {
                  Text(DateHelpers.formatDate(day.date))
                      .font(.caption)
                      .foregroundStyle(.secondary)

                  Text(day.phase.rawValue.capitalized + " Phase")
                      .font(.headline)

                  Text(workoutLabel(day.workout))
                      .font(.subheadline)
              }
              .frame(maxWidth: .infinity)
              .padding(12)
              .background(
                  RoundedRectangle(cornerRadius: 16)
                      .fill(day.phase.color.opacity(0.25))
              )
              .overlay(
                  RoundedRectangle(cornerRadius: 16)
                      .stroke(day.phase.color, lineWidth: 2)
              )
            ScrollView{
              if let advice = advice?.advice {
                  ForEach(advice, id: \.id) { item in
                      AdviceCardRow(item: item, phase: day.phase)
                  }
              }
            }
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
  }
  
  @ViewBuilder var addRaceGoal: some View {
    let colour: InfoBoxColour = .green
    VStack(alignment: .center, spacing: 8){
      Text("No Current Race Goal Set")
        .foregroundStyle(colour.textColor)
        .padding(.top, 8)
        .font(.title3)
        .bold()
      Text("Set a race goal and begin your personalised training plan")
        .padding(12)
        .foregroundStyle(colour.textColor)
        .multilineTextAlignment(.center)
      
      Button("Set a Race Goal"){
        viewModel.showAddRaceGoalModal.toggle()
      }
      .tint(.backgroundGrey)
      .bold()
      .frame(maxWidth: .infinity)
      .padding(12)
      .background(colour.textColor)
      .cornerRadius(48)
      .padding(12)
    }
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(colour.backgroundColour)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(colour.textColor, lineWidth: 2)
    )
    .padding(.horizontal, 16)
    
  }
}

func workoutLabel(_ workout: WorkoutSession?) -> String {
    guard let workout = workout else { return "Rest day" }
    if workout.session_type == "rest" { return "Rest day" }
    let dist = String(format: "%.2f", workout.distance ?? 0)
    let formatted = workout.session_type
        .split(separator: "_")
        .map { $0.capitalized }
        .joined(separator: " ")
    return "Recommended: \(dist)km \(formatted) Run"
}

struct RaceGoalCapsule: View {
  var race: RaceGoalResponse
  
  var body: some View {
    VStack(spacing: 4) {
      Text("Current Training Goal")
        .font(.caption)
        .padding(.top ,8)
      
      Text((race.race_name ?? race.race_type) ?? "No current race goal")
        .font(.headline)
        .padding(.bottom, 6)
      
      Text("Goal Finish Time: \(race.goal_time ?? "N/A")")
        .font(.headline)
        .padding(.bottom, 6)
      
      Text("Goal Race Date: \(race.race_date ?? "N/A")") //TODO: format date,
        .font(.subheadline)
        .padding(.bottom, 8)
    }
    .padding(.top, 8)
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(.accentgreen.opacity(0.25))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(.accentgreen, lineWidth: 2)
    )
  }
}


  


