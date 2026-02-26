//
//  UserSettingsView.swift
//  WeRun
//
//  Created by Aimee Daly on 29/01/2026.
//

import SwiftUI

struct UserSettingsView: View {
  
  private let trackableItems = [
      "Hydration",
      "Sleep",
      "Resting Heart Rate",
      "Energy Levels",
      "Muscle Soreness",
      "Body Temperature",
      "Anxiety",
      "Sweat Levels"
  ]


  
    @EnvironmentObject var authState: AppAuthState
    @State private var selectedTrackables: Set<TrackableItem> = []
    @State private var selectedSymptoms: Set<String> = []
    var symptoms: [String] = Symptoms.allCases.map(\.displayName)
  
    var body: some View {
      Text("User Settings")
          .font(.title)
          .bold()
          .foregroundColor(.accentPurple)
      Divider()
      ScrollView{
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("What would you like to track?")
                    .font(.headline)
                    .foregroundColor(.accentPurple)

                Spacer()

                Button("Clear all") {
                    selectedTrackables.removeAll()
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(.accentPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentPurple.opacity(0.1))
                .cornerRadius(8)
            }

            FlexibleSelectionGrid(
//                items: trackableItems,
                selections: $selectedTrackables
            )
        }
        Divider()
        
        // MARK: Symptoms
      VStack(alignment: .leading, spacing: 12) {

          HStack {
              Text("Symptoms you usually experience")
                  .font(.headline)
                  .foregroundColor(.accentPurple)

              Spacer()

              Button("Clear all") {
                  selectedSymptoms.removeAll()
              }
              .font(.caption.weight(.semibold))
              .foregroundColor(.accentPurple)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(Color.accentPurple.opacity(0.1))
              .cornerRadius(8)
          }

        FlexibleSymptomSelectionGrid(
              items: symptoms,
              selections: $selectedSymptoms
          )
      }
        Divider()
        
        Button("Log Out"){
          Task
          {
            Task {
              authState.logout()
            }
          }
        }
        .tint(.backgroundGrey)
        .bold()
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.accentRed)
        .cornerRadius(48)
        .padding(12)
      }
      .padding(.horizontal, 32)
    }
  
  struct FlexibleSelectionGrid: View {
    let items: [TrackableItem] = CreateAccountTrackables.allCases.map { trackable in
        TrackableItem(
            name: trackable.rawValue,
            value_numeric: nil,
            value_text: nil
        )
    }

      @Binding var selections: Set<TrackableItem>

      private let columns = [
          GridItem(.flexible()),
          GridItem(.flexible())
      ]

      var body: some View {
          LazyVGrid(columns: columns, spacing: 12) {
              ForEach(items, id: \.self) { item in
                  Button {
                    toggle(item)
                  } label: {
                    Text(item.name)
                          .font(.subheadline)
                          .frame(maxWidth: .infinity, minHeight: 44)
                          .background(
                              RoundedRectangle(cornerRadius: 12)
                                  .fill(selections.contains(item)
                                        ? Color.accentPurple
                                        : Color.backgroundGrey.opacity(0.2))
                          )
                          .foregroundColor(selections.contains(item) ? .white : .primary)
                  }
              }
          }
      }

    private func toggle(_ item: TrackableItem) {
        if selections.contains(item) {
              selections.remove(item)
          } else {
              selections.insert(item)
          }
      }
  }
  
  struct FlexibleSymptomSelectionGrid: View {
    let items: [String]
      @Binding var selections: Set<String>

      private let columns = [
          GridItem(.flexible()),
          GridItem(.flexible())
      ]

      var body: some View {
          LazyVGrid(columns: columns, spacing: 12) {
              ForEach(items, id: \.self) { item in
                  Button {
                    toggle(item)
                  } label: {
                    Text(item)
                          .font(.subheadline)
                          .frame(maxWidth: .infinity, minHeight: 44)
                          .background(
                              RoundedRectangle(cornerRadius: 12)
                                  .fill(selections.contains(item)
                                        ? Color.accentPurple
                                        : Color.backgroundGrey.opacity(0.2))
                          )
                          .foregroundColor(selections.contains(item) ? .white : .primary)
                  }
              }
          }
      }

    private func toggle(_ item: String) {
        if selections.contains(item) {
              selections.remove(item)
          } else {
              selections.insert(item)
          }
      }
  }
}

#Preview {
    UserSettingsView()
}
