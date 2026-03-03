//
//  MenstrualCalendarScreen.swift
//  WeRun
//
//  Created by Aimee Daly on 02/03/2026.
//

import SwiftUI
import Foundation

struct MenstrualCalendarScreen: View {
  
  @State private var selectedDay: CycleDay? // the day we press to have a modal pop up
  @State var menstrualSample: [MenstrualCycle]
  @State var today: CycleDay
  @State var dayOfCycle: Int
  
  var body: some View {
      let fullCycle = buildCalendarDays(from: menstrualSample)
      VStack(spacing: 16) {
        
        CycleStatusCard(currentDay: today)
        
//        CycleTimelineView(cycleDays: fullCycle)
        
        CalendarGridView(
          days: fullCycle,
          selectedDay: $selectedDay,
          dayOfCycle: dayOfCycle
        )
        if let selectedDay {
          BottomWorkoutPanel(day: selectedDay)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding()
//            .animation(.easeInOut, value: selectedDay?.id)
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
  
  struct CycleTimelineView: View {
    let cycleDays: [CycleDay]
    
    var body: some View {
      GeometryReader { geo in
        HStack(spacing: 0) {
          ForEach(CyclePhase.allCases, id: \.self) { phase in
            Rectangle()
              .fill(phase.color)
          }
        }
        .clipShape(Capsule())
      }
      .frame(height: 10)
    }
  }
  
  struct CalendarGridView: View {
    
    let days: [CycleDay]
    @Binding var selectedDay: CycleDay?
    let dayOfCycle: Int?
    
    private let columns = Array(
      repeating: GridItem(.flexible()),
      count: 5
    )
    
    var body: some View {
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(days) { day in
          CalendarDayCell(day: day, currentDay: dayOfCycle, dayNumber: day.dayofCycle)
            .onTapGesture {
              selectedDay = day
            }
        }
      }
    }
  }
  
  struct CalendarDayCell: View {
      let day: CycleDay
      let currentDay: Int? // current day of cycle
      let dayNumber: Int?
      
      var isToday: Bool {
          Calendar.current.isDateInToday(day.date)
      }
        
      
      var body: some View {
          ZStack {
              RoundedRectangle(cornerRadius: 10)
              .fill(day.phase.color.opacity(0.25))
              
              RoundedRectangle(cornerRadius: 10)
                  .stroke(
                    isToday ? day.phase.color.opacity(0.9) : .clear,
                      lineWidth: 2
                  )
              
              VStack(spacing: 4) {
                Text(dayNumber.map(String.init) ?? dateNumber)
                      .font(.caption)
                  
                  if day.workoutType != nil {
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
  
//  struct DayDetailSheet: View {
//    let day: CycleDay
//    
//    var body: some View {
//      VStack(alignment: .leading, spacing: 16) {
//        Text(day.phase.rawValue.capitalized)
//          .font(.title2)
//          .fontWeight(.bold)
//        
//        if let workout = day.workoutType {
//          Text("Recommended workout: \(workout)")
//        }
//        
//        Spacer()
//      }
//      .padding()
//    }
//  }
  
  struct BottomWorkoutPanel: View {
    let day: CycleDay
    
    var body: some View {
      VStack(spacing: 8) {
        
        Text("\(DateHelpers.formatDateToDayMonth(day.date))")
        Text(day.phase.rawValue.capitalized + " Phase")
          .font(.headline)
        
        if let workout = day.workoutType {
          Text("Recommended: \(workout)")
            .font(.subheadline)
        } else {
          Text("Rest day")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        
        
      }
      .frame(maxWidth: .infinity)
      .frame(height: 140)
      .background(
        RoundedRectangle(cornerRadius: 28)
          .fill(day.phase.color.opacity(0.25))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 28)
          .stroke(day.phase.color, lineWidth: 2)
      )
    }
  }
}
