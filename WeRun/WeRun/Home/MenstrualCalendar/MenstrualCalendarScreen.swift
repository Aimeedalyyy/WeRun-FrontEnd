//
//  MenstrualCalendarScreen.swift
//  WeRun
//
//  Created by Aimee Daly on 02/03/2026.
//

import SwiftUI
import Foundation


struct CalendarDay: Codable, Identifiable {
    let id = UUID()
    let day_of_cycle: Int
    let date: String
    let phase: String
    let workout_type: String?

    enum CodingKeys: String, CodingKey {
        case day_of_cycle, date, phase, workout_type
    }

    // Convert to your existing CycleDay
    func toCycleDay() -> CycleDay? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        guard let parsedDate = formatter.date(from: date) else { return nil }
        return CycleDay(
          day_of_cycle: day_of_cycle,
            date: parsedDate,
            phase: CyclePhase(rawValue: phase) ?? .follicular,
          workout_type: workout_type
        )
    }
}



struct MenstrualCalendarScreen: View {
  @State private var selectedDay: CycleDay?
  @State private var selectedIndex: Int
  @State var fullcycle: [CycleDay]
  @State private var showMenstrualCalendar = false
  @State var advice: [Advice]
  @ObservedObject var viewModel: CalendarViewModel
  
  
  
  init(cycleDays: [CycleDay], advice: [Advice], viewModel: CalendarViewModel) {
    let todayIndex = cycleDays.firstIndex(where: {
      Calendar.current.isDateInToday($0.date)
    }) ?? 0
    
    self._fullcycle = State(initialValue: cycleDays)
    self._selectedIndex = State(initialValue: todayIndex)
    self._advice = State(initialValue: advice)
    self.viewModel = viewModel
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
                DayDetailPage(
                    day: day,
                    advice: viewModel.adviceByDate[Calendar.current.startOfDay(for: day.date)]
                )
                  .tag(index)
              }
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
          .frame(height: geo.size.height)
      }
      .frame(height: UIScreen.main.bounds.height * 0.75)
      .onChange(of: selectedIndex) { oldValue, newValue in
          let day = fullcycle[newValue]

          Task {
              await viewModel.getDaysAdvice(date: day.date)
          }
      }
      
      PhaseDotsView(
        currentPhase: fullcycle[selectedIndex].phase
      )
      
    }
    .refreshable {
      print("🐞🐞 Pull to refresh !")
    }
    .onAppear(){
      Task{
        await viewModel.getDaysAdvice(date: Date())
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
          
          if day.workout_type != nil {
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

                  if let workout = day.workout_type {
                      Text("Recommended: \(workout)")
                          .font(.subheadline)
                  } else {
                      Text("Rest day")
                          .font(.subheadline)
                          .foregroundStyle(.secondary)
                  }
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

              if let advice = advice?.advice {
                  ForEach(advice, id: \.id) { item in
                      AdviceCardRow(item: item, phase: day.phase)
                  }
              }
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
  }

}


