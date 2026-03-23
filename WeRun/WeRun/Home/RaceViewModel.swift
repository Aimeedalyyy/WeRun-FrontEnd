//
//  RaceViewModel.swift
//  WeRun
//
//  Created by Aimee Daly on 23/03/2026.
//

import SwiftUI
import Foundation


class RaceViewModel: ObservableObject {

    @Published var raceGoal: RaceGoalResponse?
    @Published var isLoading: Bool = true
    @Published var submitRaceGoal: RaceGoalRequest?
    @Published var submitResponse: SubmitRaceGoalReponse?
    @Published var eventName: String = ""
    @Published var raceType: RaceTypesEnum? = nil
    @Published var eventDate: Date = Date()
    @Published var selectedHours: Int = 1
    @Published var selectedMinutes: Int = 0
    @Published var selectedSeconds: Int = 0
    @Published var showSuccessToast: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
  

    // MARK: - Computed helpers
    var canSubmit: Bool {
        raceType != nil && !isSubmitting
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: eventDate)
    }

    var formattedGoalTime: String {
        String(format: "%02d:%02d:%02d", selectedHours, selectedMinutes, selectedSeconds)
    }

    // Resets time pickers to defaults when race type changes
    func selectRaceType(_ index: Int?) {
        raceType = index.flatMap(RaceTypesEnum.init(rawValue:))
        if let rt = raceType {
            let d = rt.defaultFinishTime
            selectedHours   = d.hours
            selectedMinutes = d.minutes
            selectedSeconds = d.seconds
        }
    }

    // MARK: - Existing: fetch
    func getRaceGoal() async {
        //if raceGoal != nil { return }
        do {
            let response = try await APIManager.shared.getRaceGoal()
            DispatchQueue.main.async {
                self.raceGoal = response
                self.isLoading = false
                print("🐞🧍 raceGoal: \(response)")
            }
        } catch { print("API Error:", error) }
    }

    // MARK: - Existing: submit (with form state integrated)
    func submitRaceGoal() async {
        if submitResponse != nil { return }

        guard let raceType else { return }

        // Validate race date is in the future
        guard let raceDate = parseDate(formattedDate), raceDate > Date() else {
            DispatchQueue.main.async {
                self.errorMessage = "Race date must be in the future."
            }
            return
        }

        // Build the request from form state
        let payload = RaceGoalRequest(
            race_type: raceType.stringValue,
            race_name: eventName,
            race_date: formattedDate,
            goal_time: formattedGoalTime
        )

        DispatchQueue.main.async { self.isSubmitting = true }

        do {
            let response = try await APIManager.shared.submitRaceGoal(race: payload)
            DispatchQueue.main.async {
                self.submitResponse = response
                self.isSubmitting = false
                withAnimation { self.showSuccessToast = true }
                print("🐞🏃‍♀️ Submitted race goal: \(response)")
                
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isSubmitting = false
            }
            print("API Error:", error)
        }
    }

    // MARK: - Private
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }
}
