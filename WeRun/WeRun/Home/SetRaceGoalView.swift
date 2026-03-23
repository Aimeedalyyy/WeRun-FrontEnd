//
//  SetRaceGoalView.swift
//  WeRun
//
//  Created by Aimee Daly on 19/03/2026.
//
//

import SwiftUI

enum RaceTypesEnum: Int, CaseIterable {
    case five = 0
    case ten = 1
    case half = 2
    case marathon = 3

    var stringValue: String {
        switch self {
        case .five:     return "5k"
        case .ten:      return "10k"
        case .half:     return "half_marathon"
        case .marathon: return "marathon"
        }
    }
  
  var Label: String {
      switch self {
      case .five:     return "5k"
      case .ten:      return "10k"
      case .half:     return "Half Marathon"
      case .marathon: return "Marathon"
      }
  }


    var defaultFinishTime: (hours: Int, minutes: Int, seconds: Int) {
        switch self {
        case .five:     return (0, 30, 0)
        case .ten:      return (1, 0, 0)
        case .half:     return (2, 15, 0)
        case .marathon: return (4, 30, 0)
        }
    }

    var showHours: Bool {
        switch self {
        case .five: return false
        default:    return true
        }
    }
}

struct SetRaceGoalView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RaceViewModel

    private var canSubmit: Bool {
      viewModel.raceType != nil && !viewModel.isSubmitting
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: viewModel.eventDate)
    }

    private var formattedGoalTime: String {
      String(format: "%02d:%02d:%02d", viewModel.selectedHours, viewModel.selectedMinutes, viewModel.selectedSeconds)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Set New Race Goal")
                        .font(.title).fontWeight(.bold)
                        .foregroundColor(.accentgreen)
                        .padding(.horizontal, 32).padding(.top, 16)

                    Divider().padding(.vertical, 12)

                    // Event Name (optional)
                    HStack {
                        Text("Event Name")
                            .font(.headline).foregroundColor(.accentgreen)
                      TextField("Optional", text: $viewModel.eventName)
                            .padding()
                            .background(Color.backgroundGrey.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16).padding(.bottom, 16)

                    // Race Type
                    VStack(alignment: .leading) {
                        Text("Event Type")
                            .font(.headline).foregroundColor(.accentgreen)
                            .padding(.horizontal, 16)

                        HorizontalRaceSelector(
                          options: RaceTypesEnum.allCases.map { $0.Label },
                            selectedIndex: Binding(
                              get: { viewModel.raceType?.rawValue },
                                set: { newVal in
                                  viewModel.raceType = newVal.flatMap(RaceTypesEnum.init(rawValue:))
                                  if let rt = viewModel.raceType {
                                        let d = rt.defaultFinishTime
                                      viewModel.selectedHours   = d.hours
                                      viewModel.selectedMinutes = d.minutes
                                      viewModel.selectedSeconds = d.seconds
                                    }
                                }
                            )
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)

                    // Event Date
                    VStack(alignment: .leading) {
                        Text("Event Date")
                            .font(.headline).foregroundColor(.accentgreen)
                            .padding(.horizontal, 16)
                        HStack {
                            Spacer()
                          DatePicker("", selection: $viewModel.eventDate, displayedComponents: .date)
                                .datePickerStyle(.wheel).labelsHidden()
                            Spacer()
                        }
                        
                    }
                    //.padding(.bottom, 16)

                    // Goal Time
                    VStack(alignment: .leading) {
                        Text("Goal Finishing Time")
                            .font(.headline).foregroundColor(.accentgreen)
                            .padding(.horizontal, 16)
                        HStack {
                            Spacer()
                            FinishTimePickerView(
                              raceType: viewModel.raceType ?? .ten,
                              selectedHours: $viewModel.selectedHours,
                              selectedMinutes: $viewModel.selectedMinutes,
                              selectedSeconds: $viewModel.selectedSeconds
                            )
                            Spacer()
                        }
                        Divider().padding(.horizontal, 16)
                    }
                    .padding(.bottom, 16)

                    // Error message
                  if let error = viewModel.errorMessage {
                    Text(error)
                            .foregroundColor(.red).font(.footnote)
                            .padding(.horizontal, 32).padding(.bottom, 8)
                    }

                    // Submit button
                    Button {
                      Task { await viewModel.submitRaceGoal() }
                    } label: {
                      if viewModel.isSubmitting {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity).padding(12)
                        } else {
                            Text("Submit").bold()
                                .frame(maxWidth: .infinity).padding(12)
                        }
                    }
                    .tint(.backgroundGrey)
                    .background(canSubmit ? Color.accentgreen : Color.gray.opacity(0.4))
                    .cornerRadius(48)
                    .padding(12).padding(.horizontal, 32)
                    .disabled(!canSubmit)
                    .padding(.bottom, 40)
                }
            }

            // Toast
          if viewModel.showSuccessToast {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white).font(.title3)
                    Text("Race goal saved!")
                        .fontWeight(.semibold).foregroundColor(.white)
                }
                .padding(.horizontal, 24).padding(.vertical, 14)
                .background(Color.accentgreen)
                .cornerRadius(32)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 8)
    }
}


struct HorizontalRaceSelector: View {
    let options: [String]
    @Binding var selectedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(options.indices, id: \.self) { index in
                        Button { selectedIndex = index } label: {
                            Text(options[index])
                                .font(.subheadline)
                                .padding(.vertical, 10).padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedIndex == index
                                              ? Color.accentgreen
                                              : Color.backgroundGrey.opacity(0.2))
                                )
                                .foregroundColor(selectedIndex == index ? .white : .primary)
                        }
                    }
                }
            }
        }
    }
}

struct FinishTimePickerView: View {
    let raceType: RaceTypesEnum
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    @Binding var selectedSeconds: Int

    var body: some View {
        HStack(spacing: 0) {
            if raceType.showHours {
                Picker("Hours", selection: $selectedHours) {
                    ForEach(0...23, id: \.self) { Text("\($0)h").tag($0) }
                }
                .pickerStyle(.wheel).frame(width: 80).clipped()
            }
            Picker("Minutes", selection: $selectedMinutes) {
                ForEach(0...59, id: \.self) { Text("\($0)m").tag($0) }
            }
            .pickerStyle(.wheel).frame(width: 80).clipped()

            Picker("Seconds", selection: $selectedSeconds) {
                ForEach(0...59, id: \.self) { Text("\($0)s").tag($0) }
            }
            .pickerStyle(.wheel).frame(width: 80).clipped()
        }
    }
}

#Preview { SetRaceGoalView(viewModel: RaceViewModel()) }
