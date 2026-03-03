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
    static func from(_ string: String) -> CyclePhase {
        CyclePhase(rawValue: string.lowercased()) ?? .follicular
    }
}

struct CycleDay: Identifiable {
    let id = UUID()
    let dayofCycle: Int
    let date: Date
    let phase: CyclePhase
    let workoutType: String?
}

enum SampleData {
    
    // MARK: - Public datasets
    
//    static let cycle28: [CycleDay] = generateCycle(
//        length: 28,
//        startDate: startOfCurrentMonth
//    )
//    
//    static let cycleWithRestDays: [CycleDay] = generateCycle(
//        length: 28,
//        startDate: startOfCurrentMonth,
//        includeRestDays: true
//    )
//    
//    static let shortCycle24: [CycleDay] = generateCycle(
//        length: 24,
//        startDate: startOfCurrentMonth
//    )
    
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
