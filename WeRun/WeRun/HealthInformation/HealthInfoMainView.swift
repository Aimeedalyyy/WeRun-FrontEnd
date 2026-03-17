//
//  ContentView.swift
//  HealthKitApp
//
//  Created by Aimee Daly on 08/09/2025.
//

import SwiftUI
import HealthKit
import HealthKitUI

struct HealthInfoMainView: View {
  // 1.
  @ObservedObject var viewModel: HealthInfoViewModel
  @ObservedObject var appViewModel: AppViewModel

  
  
  // 2.
  var body: some View {
    ScrollView{
      switch viewModel.state {
      case .loading, .idle:
        loadingView
      case .loaded:
          content
            .navigationDestination(isPresented: $viewModel.showSubmissionSheet){
            SubmitData(viewModel: viewModel)
              .background(Color.gray.opacity(0.05))
          }
            .navigationDestination(isPresented: $viewModel.showDailyCheckInSheet){
              DailyCheckInView(viewModel: viewModel)
                .background(Color.gray.opacity(0.05))
            }
        
       
      case .error:
        Text(viewModel.errorMessage ?? "An unknown error occurred.")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .notAuthorized:
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
    .refreshable {
      //await viewModel.fetchMenstrualData()
      await viewModel.getUserInfo()
    }
    .onAppear(){
      Task{
        //await viewModel.fetchMenstrualData()
        await viewModel.getUserInfo()
      }
    }

    
  }
  

  @ViewBuilder var loadingView : some View{
    ProgressView("Requesting HealthKit authorization...")
      .padding()
  }
  
  @ViewBuilder var content: some View{
    Text("Health Information")
      .font(.title)
      .fontWeight(.bold)
      .foregroundStyle(.accentPink)
    ScrollView {
      InfoBox
        .padding(.bottom, 8)
      CheckInBox
        .padding(.bottom, 8)
      ForEach(viewModel.groupedTimeline, id: \.date) { group in
          dataCell(
              date: group.date,
              entries: group.items
          )
          .padding(.horizontal, 8)
      }    }
  }
  
  @ViewBuilder var InfoBox: some View {
    let colour: InfoBoxColour = .red
        VStack(alignment: .center, spacing: 8){
          Text("Submit Todays Menstration Symptoms")
            .foregroundStyle(colour.textColor)
            .padding(.top, 8)
            .font(.title3)
            .bold()
          Text("This allows us to keep our advice and analysis up to date")
            .padding(12)
            .foregroundStyle(colour.textColor)
            .multilineTextAlignment(.center)

          
          Button("Submit"){
            viewModel.showSubmissionSheet.toggle()
          }
          .tint(.backgroundGrey)
          .bold()
          .frame(maxWidth: .infinity)
          .padding(12)
          .background(colour.textColor)
          .cornerRadius(48)
          .padding(12)
        }
        .frame(maxWidth: .infinity)
        .background(colour.backgroundColour)
        .cornerRadius(12)
        .padding(.horizontal, 16)

      }
  
  @ViewBuilder var CheckInBox: some View {
    let colour: InfoBoxColour = .purple
        VStack(alignment: .center, spacing: 8){
          Text("Update your Trackable items")
            .foregroundStyle(colour.textColor)
            .padding(.top, 8)
            .font(.title3)
            .bold()
          Text("This allows us to keep our advice and analysis up to date")
            .padding(12)
            .foregroundStyle(colour.textColor)
            .multilineTextAlignment(.center)
          
          Button("Submit"){
            viewModel.showDailyCheckInSheet.toggle()
          }
          .tint(.backgroundGrey)
          .bold()
          .frame(maxWidth: .infinity)
          .padding(12)
          .background(colour.textColor)
          .cornerRadius(48)
          .padding(12)
        }
        .frame(maxWidth: .infinity)
        .background(colour.backgroundColour)
        .cornerRadius(12)
        .padding(.horizontal, 16)

      }

  
  
}


struct dataCell: View {
    let date: Date
    let entries: [TimelineEntry]

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        
        Text(formatDate(date))
          .font(.headline)
          .padding(.bottom, 4)
        
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 120), spacing: 8)],
          spacing: 8
        ) {
          ForEach(entries, id: \.self) { entry in
            capsule(entry: entry)
          }
        }
      }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
  
  @ViewBuilder
  func capsule(entry: TimelineEntry) -> some View {
      let text = buildText(entry)

      Text(text)
          .foregroundStyle(textColour(entry))
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(backgroundColour(entry))
          .foregroundColor(.white)
          .cornerRadius(20)
  }
  
  func buildText(_ entry: TimelineEntry) -> String {
      if entry.type == .symptom {
          return entry.name
      }

      var parts: [String] = [entry.name]

      if let value = entry.value {
          if let unit = entry.unit {
              parts.append("\(value) \(unit)")
          } else {
              parts.append(value)
          }
      }

      if let phase = entry.phase {
          parts.append(capitalize(phase))
      }

      return parts.joined(separator: " • ")
  }
  
  func backgroundColour(_ entry: TimelineEntry) -> Color {
      switch entry.type {
      case .trackable:
        return .backroundPurple
      case .symptom:
        return .lightRed
      }
  }
  
  func textColour(_ entry: TimelineEntry) -> Color {
      switch entry.type {
      case .trackable:
        return .accentPurple
      case .symptom:
        return .accentRed
      }
  }
  
  func capitalize(_ string: String) -> String {
      string.prefix(1).uppercased() + string.dropFirst()
  }
}


#Preview {
  
  //dataCell(dateString: "date", length: 4, dataType: .cycle)
  //HealthInfoMainView(viewModel: HealthInfoViewModel(), appViewModel: AppViewModel())
}


