//
//  CalendarHelpers.swift
//  WeRun
//
//  Created by Aimee Daly on 02/03/2026.
//

import Foundation

struct CycleAverages {
    let averageCycleLength: Int
    let averageMenstrualLength: Int
}


func currentCycle(from cycles: [MenstrualCycle]) -> MenstrualCycle? {
    // Sort by startDate descending
    return cycles.sorted { $0.startDate > $1.startDate }.first
}


func generateCycleDays(
    for currentCycle: UserCycleResponse,
    averages: CycleAverages
) -> [CycleDay] {
    
    var days: [CycleDay] = []
    let calendar = Calendar.current
    
    let menstrualLength = averages.averageMenstrualLength
    let cycleLength = averages.averageCycleLength
    
    var cycleDayNumber = 1
  
  if let startdate = currentCycle.startDate{
    // 1️⃣ Menstrual Phase
    for offset in 0..<menstrualLength {
      if let date = calendar.date(byAdding: .day, value: offset, to: startdate) {
        days.append(
          CycleDay(
            day_of_cycle: cycleDayNumber,
            date: date,
            phase: .menstruation,
            workout: nil
          )
        )
        cycleDayNumber += 1
      }
    }
    
    let lutealLength = 14
    let ovulationLength = 1    
    // Adjust follicular length to preserve total cycle length
    let follicularLength = max(
      cycleLength - menstrualLength - lutealLength - ovulationLength,
      3
    )
    
    // 2️⃣ Follicular Phase
    let follicularStart = calendar.date(
      byAdding: .day,
      value: menstrualLength,
      to: startdate
    )!
    
    for offset in 0..<follicularLength {
      if let date = calendar.date(byAdding: .day, value: offset, to: follicularStart) {
        days.append(
          CycleDay(
            day_of_cycle: cycleDayNumber,
            date: date,
            phase: .follicular,
            workout: nil
          )
        )
        cycleDayNumber += 1
      }
    }
    
    // 3️⃣ Ovulation Phase (3 days)
    let ovulationStart = calendar.date(
      byAdding: .day,
      value: follicularLength,
      to: follicularStart
    )!
    
    for offset in 0..<ovulationLength {
      if let date = calendar.date(byAdding: .day, value: offset, to: ovulationStart) {
        days.append(
          CycleDay(
            day_of_cycle: cycleDayNumber,
            date: date,
            phase: .ovulation,
            workout: nil
          )
        )
        cycleDayNumber += 1
      }
    }
    
    // 4️⃣ Luteal Phase
    let lutealStart = calendar.date(
      byAdding: .day,
      value: follicularLength + ovulationLength,
      to: follicularStart
    )!
    
    for offset in 0..<lutealLength {
      if let date = calendar.date(byAdding: .day, value: offset, to: lutealStart) {
        days.append(
          CycleDay(
            day_of_cycle: cycleDayNumber,
            date: date,
            phase: .luteal,
            workout: nil
          )
        )
        cycleDayNumber += 1
      }
    }
    
        print("🐞🗓️ Generating Cycle days for Calendar view: \(days)")
    
    return days
  } else {
    return []
  }
}

//func assignWorkouts(to days: [CycleDay]) -> [CycleDay] {
//    days.map { day in
//        var workout: String?
//        switch day.phase {
//        case .menstruation:
//            workout = ["Rest", "Easy Run", "Mobility"].randomElement()
//        case .follicular:
//            workout = ["Intervals", "Tempo Run", "Strength"].randomElement()
//        case .ovulation:
//            workout = ["Speed Session", "Race Pace"].randomElement()
//        case .luteal:
//            workout = ["Steady Run", "Long Run", "Easy Run"].randomElement()
//        }
//      return CycleDay(day_of_cycle: day.day_of_cycle, date: day.date, phase: day.phase, workout_type: workout)
//    }
//}
//

func buildCalendarDays(from cycles: [UserCycleResponse]) -> [CycleDay] {
  guard let current = cycles.sorted(by: { $0.period_start_date > $1.period_start_date }).first else {
      print("⚠️🗓️ error in building Calendar")
        return []
    }
    
    let averages = computeAverages(from: cycles)
    print("🐞🗓️ Built the calendar days! \(averages)")
    return generateCycleDays(for: current, averages: averages)
}



func computeAverages(from cycles: [UserCycleResponse]) -> CycleAverages {
    guard !cycles.isEmpty else {
        print("⚠️🗓️ returning avg of 28 and 5 (defaults)")
        return CycleAverages(averageCycleLength: 28, averageMenstrualLength: 5)
    }
    
  let sorted = cycles.sorted { $0.period_start_date < $1.period_start_date }
    
    // Average menstrual (bleeding) length
    let menstrualLengths = sorted.map { max($0.lengthInDays, 1) }
    let avgMenstrual = menstrualLengths.reduce(0, +) / menstrualLengths.count
    
    // Average full cycle length (difference between start dates)
    var cycleLengths: [Int] = []
  

    
    for i in 0..<(sorted.count - 1) {
        let days = Calendar.current.dateComponents(
            [.day],
            from: DateHelpers.Todate(from: sorted[i].period_start_date),
            to: DateHelpers.Todate(from: sorted[i + 1].period_start_date)
        ).day ?? 28
        
        cycleLengths.append(days)
    }
    
    let avgCycle = cycleLengths.isEmpty
        ? 28
        : cycleLengths.reduce(0, +) / cycleLengths.count
    
    return CycleAverages(
        averageCycleLength: avgCycle,
        averageMenstrualLength: avgMenstrual
    )
}
