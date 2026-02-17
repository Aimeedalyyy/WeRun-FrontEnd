//
//  InfoBoxColour.swift
//  WeRun
//
//  Created by Aimee Daly on 25/11/2025.
//


import SwiftUI
import Foundation


enum InfoBoxColour{
  case red
  case purple
  
  var backgroundColour: Color{
    switch self {
    case .red:
      return .infoRed
    case .purple:
      return .backroundPurple
  }
  }
    
    var textColor: Color {
      switch self {
      case .red:
        return .accentRed
      case .purple:
        return .accentPurple
      }
    }
  
  
  }


struct InfoBox: View {
  var title: String?
  var subtitle: String?
  var colour: InfoBoxColour
  
    var body: some View {
      VStack(alignment: .center, spacing: 8){
        Text("Submit Todays Information")
          .foregroundStyle(colour.textColor)
          .padding(.top, 8)
          .font(.title3)
          .bold()
        Text("This allows us to keep our advice and analysis up to date")
          .padding(12)
          .foregroundStyle(colour.textColor)
        
        Button("Submit"){
          action()
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

func action()-> Void {
  print("Button Pressed")
}


#Preview {
  InfoBox(colour: .red)
}

