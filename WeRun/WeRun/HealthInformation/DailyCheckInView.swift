//
//  DailyCheckInView.swift
//  WeRun
//
//  Created by Aimee Daly on 16/02/2026.
//

import SwiftUI



  
struct DailyCheckInView: View {
//  @ObservedObject var viewModel: HealthInfoViewModel
  @State var flow: FlowType = .two
  @State private var selectedItems: Set<String> = ["Hydration", "Resting Heart Rate", "Sleep"]
  @State private var motivation = 10.0
  @State private var isEditingMotivation = false
  @State private var hydrationAmount: Double = 0
  @State private var hydrationUnit: HydrationUnit = .litres
  @State private var restingHeartRate: String = ""
  @State private var sleepHours: Double = 0
  @State private var energyLevel: Int? = nil
  @State private var urineColour: Int? = nil
  @State private var muscleSoreness: Int? = nil

  enum HydrationUnit: String, CaseIterable {
      case litres = "Litres"
      case cups = "Cups"
  }
  let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
  
  
  var body: some View {
    ScrollView{
      Text("Daily Check In!")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.accentPurple)
        .padding(.horizontal, 32)
        .multilineTextAlignment(.center)
      
      VStack(spacing: 20) {
    
          // Hydration
          VStack(alignment: .leading, spacing: 8) {
              Text("Hydration")
                  .font(.headline)
                  .foregroundColor(.accentPurple)

              HStack {
                  TextField("Amount", value: $hydrationAmount, format: .number)
                      .keyboardType(.decimalPad)
                      .padding()
                      .background(.backgroundGrey.opacity(0.2))
                      .cornerRadius(12)

                  Picker("", selection: $hydrationUnit) {
                      ForEach(HydrationUnit.allCases, id: \.self) {
                          Text($0.rawValue)
                      }
                  }
                  .pickerStyle(.segmented)
                  .frame(width: 150)
              }
          }

          // Resting Heart Rate
          VStack(alignment: .leading, spacing: 8) {
              Text("Resting Heart Rate")
                  .font(.headline)
                  .foregroundColor(.accentPurple)

              TextField("BPM", text: $restingHeartRate)
                  .keyboardType(.numberPad)
                  .padding()
                  .background(.backgroundGrey.opacity(0.2))
                  .cornerRadius(12)

              Text("Measure after sitting calmly for 5 minutes, then count beats for 30 seconds, and double it !")
                  .font(.caption)
                  .foregroundColor(.secondary)
          }

          // Sleep
          VStack(alignment: .leading, spacing: 8) {
              Text("Sleep")
                  .font(.headline)
                  .foregroundColor(.accentPurple)

              TextField("Hours", value: $sleepHours, format: .number)
                  .keyboardType(.decimalPad)
                  .padding()
                  .background(.backgroundGrey.opacity(0.2))
                  .cornerRadius(12)
          }

      }
      .padding(.horizontal, 32)
      .padding(.top, 12)
      VStack(spacing: 20) {

          HorizontalScaleSelector(
              title: "Energy Levels",
              options: ["Exhausted", "Tired", "OK", "Energised", "Fully Energised"],
              selectedIndex: $energyLevel
          )

          HorizontalScaleSelector(
              title: "Urine Colour",
              options: ["Clear", "Yellow", "Dark"],
              selectedIndex: $urineColour
          )

          HorizontalScaleSelector(
              title: "Muscle Soreness",
              options: ["Stiff", "Okay", "Heavy"],
              selectedIndex: $muscleSoreness
          )

      }
      .padding(.horizontal, 32)
      .padding(.top, 12)

      Button("Submit"){
        Task
        {
          clearSelectedItems()
//          await viewModel.saveData(flow: flow.intValue, date: Date(), symptoms: Array(selectedItems))
          
          
        }
      }
      .tint(.backgroundGrey)
      .bold()
      .frame(maxWidth: .infinity)
      .padding(12)
      .background(.accentPurple)
      .cornerRadius(48)
      .padding(12)
      .padding(.horizontal, 32)
    }
  }
  
  
  
  private func toggleSelection(for item: String) {
    if selectedItems.contains(item) {
      selectedItems.remove(item)
    } else {
      selectedItems.insert(item)
    }
  }
  
  private func clearSelectedItems() {
    selectedItems.removeAll()
    motivation = 0
  }
  
  
}


struct CheckInStyledPicker: View {
    @Binding var flow: FlowType
  
      
    init(flow: Binding<FlowType>) {
      self._flow = flow
        UISegmentedControl.appearance().setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
      UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.accentPurple)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().backgroundColor = .white
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("What view would you like", selection: $flow) {
              ForEach(FlowType.allCases , id: \.self) {
                    Text("\($0.string.capitalized)")
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct HorizontalScaleSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.accentPurple)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(options.indices, id: \.self) { index in
                        Button {
                            selectedIndex = index
                        } label: {
                            Text(options[index])
                                .font(.subheadline)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedIndex == index
                                              ? Color.accentPurple
                                              : Color.backgroundGrey.opacity(0.2))
                                )
                                .foregroundColor(selectedIndex == index ? .white : .primary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
          Divider()
        }
    }
}



#Preview {
    DailyCheckInView()
}
