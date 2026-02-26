//
//  RegisterView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//


import SwiftUI

enum CreateAccountTrackables: String, CaseIterable {
    case hydration = "Hydration"
    case sleep = "Sleep"
    case restingHeartRate = "Resting Heart Rate"
    case energyLevels = "Energy Levels"
    case muscleSoreness = "Muscle Soreness"
    case bodyTemperature = "Body Temperature"
    case anxiety = "Anxiety"
    case sweatLevels = "Sweat Levels"
}

struct CreateAccountView: View {
    @StateObject var viewModel: AuthViewModel
//    @State var createAccountViewModel: CreateAccountViewModel = CreateAccountViewModel()


    let trackableNames = CreateAccountTrackables.allCases.map { $0.rawValue }

  
  var symptoms: [String] = Symptoms.allCases.map(\.displayName)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Create your account")
                        .font(.title.bold())
                        .foregroundColor(.accentPurple)

                    Text("Set up your tracking preferences to personalise insights.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // MARK: Account Fields
                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }

                // MARK: Trackable Items
              VStack(alignment: .leading, spacing: 12) {

                  HStack {
                      Text("What would you like to track?")
                          .font(.headline)
                          .foregroundColor(.accentPurple)

                      Spacer()

                      Button("Clear all") {
                        viewModel.trackableSet.removeAll()
                      }
                      .font(.caption.weight(.semibold))
                      .foregroundColor(.accentPurple)
                      .padding(.horizontal, 10)
                      .padding(.vertical, 6)
                      .background(Color.accentPurple.opacity(0.1))
                      .cornerRadius(8)
                  }

                  FlexibleSelectionGrid(
                      selections: $viewModel.trackableSet
                  )
              }

                // MARK: Symptoms
              VStack(alignment: .leading, spacing: 12) {

                  HStack {
                      Text("Symptoms you usually experience")
                          .font(.headline)
                          .foregroundColor(.accentPurple)

                      Spacer()

                      Button("Clear all") {
                        viewModel.selectedSymptoms.removeAll()
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
                    selections: $viewModel.selectedSymptoms
                  )
              }

              Button {
                  Task {
                      await viewModel.createAccount()
                      await viewModel.authenticate()
                  }
              } label: {
                  Text("Create Account")
                      .frame(maxWidth: .infinity)
                      .padding()
                      .background(Color.accentPurple)
                      .foregroundColor(.white)
                      .cornerRadius(14)
                      .fontWeight(.semibold)
              }


              Spacer(minLength: 20)

              // MARK: NavigationLink to HomeView
              NavigationLink(
                  destination: HomeView(),
                  isActive: $viewModel.isLoggedIn,
                  label: { EmptyView() }
              )

            }
            .padding(24)
        }
        .navigationTitle("Register")
    }
  
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


#Preview {
  CreateAccountView(viewModel: AuthViewModel())
}
