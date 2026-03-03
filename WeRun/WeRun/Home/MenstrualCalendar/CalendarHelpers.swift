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
    for currentCycle: MenstrualCycle,
    averages: CycleAverages
) -> [CycleDay] {
    
    var days: [CycleDay] = []
    let calendar = Calendar.current
    
    let menstrualLength = averages.averageMenstrualLength
    let cycleLength = averages.averageCycleLength
    
    var cycleDayNumber = 1
    
    // 1️⃣ Menstrual Phase
    for offset in 0..<menstrualLength {
        if let date = calendar.date(byAdding: .day, value: offset, to: currentCycle.startDate) {
            days.append(
                CycleDay(
                    dayofCycle: cycleDayNumber,
                    date: date,
                    phase: .menstruation,
                    workoutType: nil
                )
            )
            cycleDayNumber += 1
        }
    }
    
    // Ovulation occurs ~14 days before next cycle
    let lutealLength = 14
    let follicularLength = max(cycleLength - menstrualLength - lutealLength - 1, 3)
    
    // 2️⃣ Follicular Phase
    let follicularStart = calendar.date(byAdding: .day, value: menstrualLength, to: currentCycle.startDate)!
    
    for offset in 0..<follicularLength {
        if let date = calendar.date(byAdding: .day, value: offset, to: follicularStart) {
            days.append(
                CycleDay(
                    dayofCycle: cycleDayNumber,
                    date: date,
                    phase: .follicular,
                    workoutType: nil
                )
            )
            cycleDayNumber += 1
        }
    }
    
    // 3️⃣ Ovulation Day
    if let ovulationDate = calendar.date(byAdding: .day, value: follicularLength, to: follicularStart) {
        days.append(
            CycleDay(
                dayofCycle: cycleDayNumber,
                date: ovulationDate,
                phase: .ovulation,
                workoutType: nil
            )
        )
        cycleDayNumber += 1
    }
    
    // 4️⃣ Luteal Phase
    let lutealStart = calendar.date(byAdding: .day, value: follicularLength + 1, to: follicularStart)!
    
    for offset in 0..<lutealLength {
        if let date = calendar.date(byAdding: .day, value: offset, to: lutealStart) {
            days.append(
                CycleDay(
                    dayofCycle: cycleDayNumber,
                    date: date,
                    phase: .luteal,
                    workoutType: nil
                )
            )
            cycleDayNumber += 1
        }
    }
    
    print("🐞🐞 Generating Cycle days for Calendar view: \(days)")
    
    return days
}

func assignWorkouts(to days: [CycleDay]) -> [CycleDay] {
    days.map { day in
        var workout: String?
        switch day.phase {
        case .menstruation:
            workout = ["Rest", "Easy Run", "Mobility"].randomElement()
        case .follicular:
            workout = ["Intervals", "Tempo Run", "Strength"].randomElement()
        case .ovulation:
            workout = ["Speed Session", "Race Pace"].randomElement()
        case .luteal:
            workout = ["Steady Run", "Long Run", "Easy Run"].randomElement()
        }
      return CycleDay(dayofCycle: day.dayofCycle, date: day.date, phase: day.phase, workoutType: workout)
    }
}


func buildCalendarDays(from cycles: [MenstrualCycle]) -> [CycleDay] {
    guard let current = cycles.sorted(by: { $0.startDate > $1.startDate }).first else {
      print("⚠️⚠️ error in building Calendar")
        return []
    }
    
    let averages = computeAverages(from: cycles)
    print("🐞🐞 Built the calendar days! \(averages)")
    return generateCycleDays(for: current, averages: averages)
}


//func buildCalendarDays(from cycles: [MenstrualCycle]) -> [CycleDay] {
//    guard let current = currentCycle(from: cycles) else { return [] }
//    
//    let predictedDays = generateCycleDays(for: current)
//    let daysWithWorkouts = assignWorkouts(to: predictedDays)
//    
//    print("🐞🐞 Built the calendar days! \(daysWithWorkouts)")
//    
//    return daysWithWorkouts
//}

func computeAverages(from cycles: [MenstrualCycle]) -> CycleAverages {
    guard !cycles.isEmpty else {
        print("⚠️⚠️ returning avg of 28 and 5 (defaults)")
        return CycleAverages(averageCycleLength: 28, averageMenstrualLength: 5)
    }
    
    let sorted = cycles.sorted { $0.startDate < $1.startDate }
    
    // Average menstrual (bleeding) length
    let menstrualLengths = sorted.map { max($0.lengthInDays, 1) }
    let avgMenstrual = menstrualLengths.reduce(0, +) / menstrualLengths.count
    
    // Average full cycle length (difference between start dates)
    var cycleLengths: [Int] = []
    
    for i in 0..<(sorted.count - 1) {
        let days = Calendar.current.dateComponents(
            [.day],
            from: sorted[i].startDate,
            to: sorted[i + 1].startDate
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
