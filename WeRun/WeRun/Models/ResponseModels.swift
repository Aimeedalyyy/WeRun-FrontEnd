//
//  ResponseModels.swift
//  WeRun
//
//  Created by Aimee Daly on 03/12/2025.
//


import Foundation

// MARK: - Analysis / Phase Comparison Models

struct PhaseComparisonResponse: Codable {
    let current_cycle: Int?
    let previous_cycle: Int?
    let phases: [PhaseStats]
}

struct PhaseStats: Codable, Hashable, Identifiable {
    let id = UUID()
    let phase: String
    let current_avg_pace: Double?
    let current_avg_motivation: Double?
    let pace_change_percent: Double?
    let motivation_change_percent: Double?
    let pace_improved: Bool?
}

// MARK: - Test Endpoint

struct TestResponse: Codable {
    let test_name: String
    let test_number: Int
    let current_date: String
    let calculated_phase: String
    let cycle_day: Int
    let days_until_next_phase: Int
  
}


// MARK: - Run Entry Request

struct RunEntryRequest: Codable {
    let date: String
    let pace: Double
    let distance: Double
    let motivation_level: Int
    let last_period_start: String
}

// MARK: - Sync Period Response

struct SyncPeriodResponse: Codable {
    let current_phase: PhaseInfo
    let historical_stats: HistoricalStats
    let recommendations: [String]
}

struct PhaseInfo: Codable {
    let phase: String
    let cycle_day: Int
}

struct HistoricalStats: Codable {
    let avg_pace: Double?
    let avg_motivation: Double?
    let total_entries: Int?
}

struct JWTResponse: Codable {
    let access: String
    let refresh: String
}

struct RegisterResponse: Codable {
    let id: Int
    let username: String
    let email: String
    let affiliated_user: Int?
}

struct LogTrackableResponse: Codable {
    let id: String
    let value_numeric: String?
    let value_text: String?
}

struct userTrackableResponse: Codable {
  let trackables: [String]
  let symptoms: [String]
}

struct UserInfoResponse: Codable {
    let trackables: [UserTrackables]
    let symptoms: [UserSymptomsResponse]
    let cycles: [UserCycleResponse]
    let current_cycle: UserCurrentCycleResponse?
}

struct UserTrackables: Codable {
    let id: String
    let name: String
    let date: String
    let value_numeric: String?
    let value_text: String?
    let unit: String?
    let phase: String?
    let cycle_day: Int?
}

struct UserSymptomsResponse: Codable {
    let id: String
    let symptom_name: String
    let date: String
    let phase: String?
    let cycle_day: Int?
    let notes: String?
}

struct UserCycleResponse: Codable {
    let id: String
    let period_start_date: String
    let period_end_date: String
    let notes: String?
}

extension UserCycleResponse {

    var startDate: Date? {
      DateHelpers.Todate(from: period_start_date)
    }

    var endDate: Date? {
      DateHelpers.Todate(from: period_end_date)

    }

    var lengthInDays: Int {
        guard let start = startDate, let end = endDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        return days + 1   // include start day
    }
}

struct UserSample: Codable {
    let id: String
    let date_logged: String
    let flow_type: Int
    let notes: String?
    let symptoms: [String]
}

struct UserCurrentCycleResponse: Codable {
  //
    let calculated_phase: String
    let cycle_day: Int
    let days_until_next_phase: Int
    let last_period_start: String
}
                 
struct AdviceResponse: Codable{
  let date: String
  let phase: String
  let cycle_day: Int
  let advice: [Advice]
}

struct Advice: Codable{
  let id: String
  let body: String
  let phase: String
  let title: String
  let category: String
  let priority: Int
}

struct RaceGoalResponse: Decodable, Encodable  {
  let has_race_goal: Bool
  let id: String?
  let race_name: String?
  let race_type: String?
  let race_date: String?
  let goal_time: String?
  let is_active: Bool?
  let created_at: String?
}


struct SubmitRaceGoalReponse: Codable {
    let success: Bool
    let id: String
    let race_name: String
    let race_type: String
    let race_date: String
    let goal_time: String
    let is_active: Bool
    let schedule: RaceSchedule
}

struct RaceSchedule: Codable {
    let total_weeks: Int
    let total_sessions: Int
    let run_days_per_week: Int
    let session_types: SessionTypes
    let phase_breakdown: PhaseBreakdown
    let first_session: String
    let last_session: String
    let phase_warnings: [String]
}

struct SessionTypes: Codable {
    let easy: Int
    let moderate: Int
    let rest: Int
    let long_run: Int
}

struct PhaseBreakdown: Codable {
    let luteal: Int?
    let menstruation: Int?
    let follicular: Int?
    let ovulatory: Int?   // not in this sample but exists as a phase

    enum CodingKeys: String, CodingKey {
        case luteal       = "Luteal"
        case menstruation = "Menstruation"
        case follicular   = "Follicular"
        case ovulatory    = "Ovulatory"
    }
}

struct WorkoutSession: Decodable, Encodable{
  let session_type: String
  let distance: Double?
}

struct CycleDay: Identifiable, Codable {
    var id = UUID()

    let day_of_cycle: Int
    let date: Date
    let phase: CyclePhase
    let workout: WorkoutSession?
  
  enum CodingKeys: String, CodingKey {
      case day_of_cycle
      case date
      case phase
      case workout
  }
}


