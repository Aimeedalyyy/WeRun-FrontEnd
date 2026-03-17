//
//  CyclePhase.swift
//  WeRun
//
//  Created by Aimee Daly on 02/03/2026.
//

import SwiftUI
import Foundation

enum CyclePhase: String, CaseIterable, Codable {
    case menstruation
    case follicular
    case ovulation
    case luteal
    
    var color: Color {
        switch self {
        case .menstruation: return .accentRed
        case .follicular: return .accentgreen
        case .ovulation: return .accentPurple
        case .luteal: return .accentPink
        }
    }
}

extension CyclePhase {
    static func from(_ string: String?) -> CyclePhase {
      if let string = string {
        return CyclePhase(rawValue: string.lowercased()) ?? .follicular
      }
      else { return .follicular }
    }
}

struct CycleDay: Identifiable, Codable {
    let id = UUID()
    let day_of_cycle: Int
    let date: Date
    let phase: CyclePhase
    let workout_type: String?

    enum CodingKeys: String, CodingKey {
        case day_of_cycle, date, phase, workout_type
    }

    // Memberwise init for use throughout the codebase
    init(day_of_cycle: Int, date: Date, phase: CyclePhase, workout_type: String?) {
        self.day_of_cycle = day_of_cycle
        self.date = date
        self.phase = phase
        self.workout_type = workout_type
    }

    // Decodable init for JSON parsing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        day_of_cycle = try container.decode(Int.self, forKey: .day_of_cycle)
        phase = try container.decode(CyclePhase.self, forKey: .phase)
        workout_type = try container.decodeIfPresent(String.self, forKey: .workout_type)

        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        guard let parsedDate = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        date = parsedDate
    }
}


enum SampleData {
    // MARK: - Generator
    
//    private static func generateCycle(
//        length: Int,
//        startDate: Date,
//        includeRestDays: Bool = false
//    ) -> [CycleDay] {
//        
//      (0..<length).map { offset in
//        let date = Calendar.current.date(
//          byAdding: .day,
//          value: offset,
//          to: startDate
//        )!
//        
//        let phase = phaseForDay(offset, cycleLength: length)
//        let workout = workoutForPhase(phase, includeRestDays: includeRestDays)
//        
//        return CycleDay(
//          date: date,
//          phase: phase,
//          workoutType: workout
//        )
//      }
//    }
    
    // MARK: - Phase Logic
    
    private static func phaseForDay(_ day: Int, cycleLength: Int) -> CyclePhase {
        
        // Simple physiological approximation
        switch day {
        case 0..<5:
            return .menstruation
        case 5..<13:
            return .follicular
        case 13..<16:
            return .ovulation
        default:
            return .luteal
        }
    }
    
    // MARK: - Workout Mapping
    
    private static func workoutForPhase(
        _ phase: CyclePhase,
        includeRestDays: Bool
    ) -> String? {
        
        if includeRestDays && Bool.random() {
            return nil
        }
        
        switch phase {
        case .menstruation:
            return ["Rest", "Easy Run", "Mobility"].randomElement()
        case .follicular:
            return ["Intervals", "Tempo Run", "Strength"].randomElement()
        case .ovulation:
            return ["Race Pace", "Speed Session"].randomElement()
        case .luteal:
            return ["Steady Run", "Long Run", "Easy Run"].randomElement()
        }
    }
    
    // MARK: - Helpers
    
    private static var startOfCurrentMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components)!
    }
}
