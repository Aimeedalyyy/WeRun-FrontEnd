//
//  DailyCheckInView.swift
//  WeRun
//
//  Created by Aimee Daly on 16/02/2026.
//

import SwiftUI

enum HydrationUnit: String, CaseIterable {
    case litres = "Litres"
    case cups = "Cups"
}

struct TrackableItem {
    let name: String
    let valueNumeric: Double
}

  
struct DailyCheckInView: View {
  @ObservedObject var viewModel: HealthInfoViewModel
  @State var flow: FlowType = .two
  @State private var hydrationAmount: Double = 0
  @State private var hydrationUnit: HydrationUnit = .litres
  @State private var restingHeartRate: String = ""
  @State private var sleepHours: Double = 0
  @State private var bodyTemperature: Double = 0
  @State private var energyLevel: EnergyLevel? = nil
  @State private var urineColour: UrineColour? = nil
  @State private var muscleSoreness: MuscleSoreness? = nil
  @State private var sweatLevel: SweatLevel? = nil
  @State private var anxietyLevel: AnxietyLevel? = nil
  @State private var trackHydration = true
  @State private var trackSleep = true
  @State private var trackHeartRate = true
  @State private var trackBodyTemp = true
  @State private var trackEnergyLevels = true
  @State private var trackUrineColour = true
  @State private var trackMuscleSoreness = true
  @State private var trackSweatLevels = true
  @State private var trackAnxiety = true



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

            Toggle(isOn: $trackHydration) {
                Text("Hydration")
                    .font(.headline)
                    .foregroundColor(.accentPurple)
            }
            .tint(.accentPurple)

            if trackHydration {
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
                .transition(.opacity.combined(with: .slide))
            }
        }
        Divider()
  
        // Resting Heart Rate
        VStack(alignment: .leading, spacing: 8) {
          Toggle(isOn: $trackHeartRate) {
              Text("Resting Heart Rate")
                  .font(.headline)
                  .foregroundColor(.accentPurple)
          }
          .tint(.accentPurple)
          
          if trackHeartRate{
            TextField("BPM", text: $restingHeartRate)
              .keyboardType(.numberPad)
              .padding()
              .background(.backgroundGrey.opacity(0.2))
              .cornerRadius(12)
            
            Text("Measure after sitting calmly for 5 minutes, then count beats for 30 seconds, and double it !")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        Divider()
        
        // Sleep
        VStack(alignment: .leading, spacing: 8) {
          Toggle(isOn: $trackSleep) {
              Text("Sleep")
                  .font(.headline)
                  .foregroundColor(.accentPurple)
          }
          .tint(.accentPurple)
          
          if trackSleep{
            TextField("Hours", value: $sleepHours, format: .number)
              .keyboardType(.decimalPad)
              .padding()
              .background(.backgroundGrey.opacity(0.2))
              .cornerRadius(12)
            
            Text("Measured in Approximately Hours")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        Divider()
        
        // Body Temperature
        VStack(alignment: .leading, spacing: 8) {
          Toggle(isOn: $trackBodyTemp) {
              Text("Body Temperature")
                  .font(.headline)
                  .foregroundColor(.accentPurple)
          }
          .tint(.accentPurple)
          
          if trackBodyTemp{
            TextField("Body Temperature", value: $bodyTemperature, format: .number)
              .keyboardType(.decimalPad)
              .padding()
              .background(.backgroundGrey.opacity(0.2))
              .cornerRadius(12)
          }
        }
        Divider()
        
      }
      .padding(.horizontal, 32)
      .padding(.top, 12)
      VStack(spacing: 20) {
        
        VStack(alignment: .leading, spacing: 8) {
          
          Toggle("Energy Levels", isOn: $trackEnergyLevels)
            .font(.headline)
            .foregroundColor(.accentPurple)
            .tint(.accentPurple)
          
          if trackEnergyLevels {
            HorizontalScaleSelector(
              options: EnergyLevel.allCases.map { $0.label },
              selectedIndex: Binding(
                get: { energyLevel?.rawValue },
                set: { energyLevel = $0.flatMap(EnergyLevel.init(rawValue:)) }
              )
            )
            .transition(.opacity.combined(with: .slide))
          }
        }
        
        VStack{
          Toggle("Urine Colour", isOn: $trackUrineColour)
            .font(.headline)
            .foregroundColor(.accentPurple)
            .tint(.accentPurple)
          
          if trackUrineColour{
            HorizontalScaleSelector(
              options: UrineColour.allCases.map { $0.label },
              selectedIndex: Binding(
                get: { urineColour?.rawValue },
                set: { urineColour = $0.flatMap(UrineColour.init(rawValue:)) }
              )
            )
          }
        }
        
        VStack{
          Toggle("Muscle Soreness", isOn: $trackMuscleSoreness)
            .font(.headline)
            .foregroundColor(.accentPurple)
            .tint(.accentPurple)
          
          if trackMuscleSoreness{
            HorizontalScaleSelector(
              options: MuscleSoreness.allCases.map { $0.label },
              selectedIndex: Binding(
                get: { muscleSoreness?.rawValue },
                set: { muscleSoreness = $0.flatMap(MuscleSoreness.init(rawValue:)) }
              )
            )
          }
          
        }
        
        VStack{
          Toggle("Sweat Level", isOn: $trackSweatLevels)
            .font(.headline)
            .foregroundColor(.accentPurple)
            .tint(.accentPurple)
          
          if trackSweatLevels{
            HorizontalScaleSelector(
              options: SweatLevel.allCases.map { $0.label },
              selectedIndex: Binding(
                get: { sweatLevel?.rawValue },
                set: { sweatLevel = $0.flatMap(SweatLevel.init(rawValue:)) }
              )
            )
          }
          
        }
        
        VStack{
          Toggle("Anxiety", isOn: $trackAnxiety)
            .font(.headline)
            .foregroundColor(.accentPurple)
            .tint(.accentPurple)
          
          if trackAnxiety{
            HorizontalScaleSelector(
              options: AnxietyLevel.allCases.map { $0.label },
              selectedIndex: Binding(
                get: { anxietyLevel?.rawValue },
                set: { anxietyLevel = $0.flatMap(AnxietyLevel.init(rawValue:)) }
              )
            )
          }
          
        }
      }
      .padding(.horizontal, 32)
      .padding(.top, 12)
      
      Button("Submit"){
        Task
        {
          Task {
              let trackables = buildTrackables()
              await viewModel.sendTrackables(trackables)
              clearSelectedItems()
          }
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
  
  private func clearSelectedItems() {
    hydrationAmount = 0.0
    hydrationUnit = .litres
    sleepHours = 0
    restingHeartRate = ""
    energyLevel = nil
    urineColour = nil
    muscleSoreness = nil
    sweatLevel = nil
    anxietyLevel = nil
  }
  
  private func buildTrackables() -> [TrackableItem] {
      var items: [TrackableItem] = []

      // Hydration
      if trackHydration, hydrationAmount > 0 {
          let valueInLitres = hydrationUnit == .cups
              ? hydrationAmount * 0.236588
              : hydrationAmount

          items.append(
              TrackableItem(
                  name: "Hydration",
                  valueNumeric: valueInLitres
              )
          )
      }

      // Resting Heart Rate
    if trackHeartRate, let bpm = Double(restingHeartRate) {
          items.append(
              TrackableItem(
                  name: "Resting Heart Rate",
                  valueNumeric: bpm
              )
          )
      }

      // Sleep
      if trackSleep, sleepHours > 0 {
          items.append(
              TrackableItem(
                  name: "Sleep",
                  valueNumeric: sleepHours
              )
          )
      }

      // Energy Level
    if trackEnergyLevels, let energyLevel {
          items.append(
              TrackableItem(
                  name: "Energy Level",
                  valueNumeric: Double(energyLevel.rawValue)
              )
          )
      }

      // Urine Colour
    if trackUrineColour, let urineColour {
          items.append(
              TrackableItem(
                  name: "Urine Colour",
                  valueNumeric: Double(urineColour.rawValue)
              )
          )
      }

      // Muscle Soreness
    if trackMuscleSoreness, let muscleSoreness {
          items.append(
              TrackableItem(
                  name: "Muscle Soreness",
                  valueNumeric: Double(muscleSoreness.rawValue)
              )
          )
      }

      return items
  }}


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
    let options: [String]
    @Binding var selectedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
  DailyCheckInView(viewModel: HealthInfoViewModel())
}
