//
//  SubmitData.swift
//  HealthKitApp
//
//  Created by Aimee Daly on 10/09/2025.
//


import SwiftUI

enum FlowType: String, CaseIterable {
  case one // no flow
  case two // light flow
  case three // medium flow
  case four // heavy
  
  var string: String{
    switch self {
    case .one:
      return "no flow"
    case .two:
      return "light"
    case .three:
      return "medium"
    case .four:
      return "heavy"
    }
  }
  
  var intValue: Int{
    switch self{
    case .one:
      return 1
    case .two:
      return 2
    case .three:
      return 3
    case .four:
      return 4
    }
  }
}

struct SubmitData: View {
  @ObservedObject var viewModel: HealthInfoViewModel
  @State var flow: FlowType = .two
  @State private var selectedItems: Set<Symptoms> = []
  @State private var motivation = 10.0
  @State private var isEditingMotivation = false
  let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
  
  
  var body: some View {
    ScrollView{
      Text("Todays Data!")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.accentRed)
        .padding(.horizontal, 32)
        .multilineTextAlignment(.center)
      
      Text("How heavy was your flow today?")
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.accentRed)
        .padding(.top, 8)
      StyledPicker(flow: $flow)
        .padding(.horizontal, 20)
        .tint(.accentRed)
        .pickerStyle(.segmented)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
      
      Text("Did you have any other associated symptoms?")
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.accentRed)
      
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(Symptoms.allCases, id: \.self) { item in
              Button(action: {
                  toggleSelection(for: item)
              }) {
                Text(item.displayName)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 60)
              }
              .buttonStyle(SelectableButtonStyle(isSelected: selectedItems.contains(item)))
          }
      }
      .padding()
    
      
      Button("Submit"){
        Task
        {
          print("flow: \(flow.intValue), date: \(Date())")
          clearSelectedItems()
          await viewModel.saveData(flow: flow.intValue, date: Date(), symptoms: Array(selectedItems))
          
          
        }
      }
      .tint(.backgroundGrey)
      .bold()
      .frame(maxWidth: .infinity)
      .padding(12)
      .background(.accentRed)
      .cornerRadius(48)
      .padding(12)
      .padding(.horizontal, 32)
    }
  }
  
  private func toggleSelection(for item: Symptoms) {
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

struct StyledPicker: View {
    @Binding var flow: FlowType
  
      
    init(flow: Binding<FlowType>) {
      self._flow = flow
        UISegmentedControl.appearance().setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.accentRed)
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


struct SelectableButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(isSelected ? .accentRed : Color.gray.opacity(0.4), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: isSelected ? .gray.opacity(0.4) : .clear,
                                    radius: isSelected ? 6 : 0,
                                    x: 0, y: isSelected ? 4 : 0)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}



#Preview {
  SubmitData(viewModel: HealthInfoViewModel())
}
