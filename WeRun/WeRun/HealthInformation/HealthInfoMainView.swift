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

  
  
  // 2.
  var body: some View {
    VStack{
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
              DailyCheckInView()//viewModel: viewModel
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
    .onAppear(){
      Task{
        print("onAppear")
        await viewModel.fetchMenstrualData()
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
      ForEach(viewModel.menstrualData , id: \.self){ data in
        dataCell(dateString: viewModel.DateToDisplay(startDate: data.startDate, endDate: data.endDate),length: data.lengthInDays)
          .padding(.horizontal, 8)
      }
    }
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
            print("button pressed")
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
            print("button pressed")
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
  let dateString: String
  let length: Int

  var body: some View {
    HStack{
      Text(dateString)
      Spacer()
      Text("\(String(length)) days")
    }
    .padding(.horizontal)
    .padding(.vertical, 24)
    .background(.lightRed)
    .cornerRadius(10)

  }
}


#Preview {
  HealthInfoMainView(viewModel: HealthInfoViewModel())
}


