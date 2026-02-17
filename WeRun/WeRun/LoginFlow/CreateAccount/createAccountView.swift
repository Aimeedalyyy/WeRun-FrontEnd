//
//  RegisterView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//


import SwiftUI

struct CreateAccountView: View {
    @StateObject var viewModel: AuthViewModel
    @State private var selectedTrackables: Set<String> = []
    @State private var selectedSymptoms: Set<String> = []

    private let trackableItems = [
        "Hydration",
        "Sleep",
        "Resting Heart Rate",
        "Energy Levels",
        "Muscle Soreness"
    ]

    private let symptoms = [
        "Cramps",
        "Headaches",
        "Bloating",
        "Fatigue",
        "Mood Changes"
    ]

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
                      items: trackableItems,
                      selections: $selectedTrackables
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
                          selectedSymptoms.removeAll()
                      }
                      .font(.caption.weight(.semibold))
                      .foregroundColor(.accentPurple)
                      .padding(.horizontal, 10)
                      .padding(.vertical, 6)
                      .background(Color.accentPurple.opacity(0.1))
                      .cornerRadius(8)
                  }

                  FlexibleSelectionGrid(
                      items: symptoms,
                      selections: $selectedSymptoms
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
//              .disabled(viewModel.isLoading || vniewModel.username.isEmpty || viewModel.password.isEmpty)

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
