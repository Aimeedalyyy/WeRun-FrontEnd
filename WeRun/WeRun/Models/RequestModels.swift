//
//  RequestModels.swift
//  WeRun
//
//  Created by Aimee Daly on 25/02/2026.
//
import Foundation

struct LogTrackableRequest: Codable, Hashable {
    let name: String
    let value_numeric: Double
    let value_text: String?
}

struct RegisterRequest: Codable {
  let username: String
  let email: String
  let password: String
  let affiliated_user: Int?
  let last_period_sync: Date?
  let last_period_start: Date?
  let last_period_end: Date?
  let trackables: [LogTrackableRequest]?
  let symptoms: [String]?
}




struct LoginRequest: Codable {
    let username: String
    let password: String
}
