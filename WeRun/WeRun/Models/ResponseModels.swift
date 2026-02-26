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
    let current_avg_pace: Double
    let current_avg_motivation: Double
    let pace_change_percent: Double
    let motivation_change_percent: Double
    let pace_improved: Bool
}

// MARK: - Test Endpoint

struct TestResponse: Codable {
    let test_name: String
    let test_number: Int
    let current_date: String
    let calculated_phase: String
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
