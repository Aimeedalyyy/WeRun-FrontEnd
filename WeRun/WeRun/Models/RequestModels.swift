//
//  RequestModels.swift
//  WeRun
//
//  Created by Aimee Daly on 25/02/2026.
//

struct LogTrackableRequest: Codable {
    let name: String
    let value_numeric: Double
    let value_text: String?
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let affiliated_user: Int?
}


struct LoginRequest: Codable {
    let username: String
    let password: String
}
