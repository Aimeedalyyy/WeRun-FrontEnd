//
//  AnalysisMainView.swift
//  WeRun
//
//  Created by Aimee Daly on 28/11/2025.
//

import SwiftUI
import Charts


struct AnalysisMainView: View {
  @ObservedObject var viewModel: AnalysisViewModel
  @State var analysis: Analysis = .one
  var body: some View {
    VStack{
      AnalysisPicker(analysis: $analysis)
        .padding(.horizontal, 20)
        .tint(.accentPurple)
        .pickerStyle(.segmented)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
      VStack {
        switch analysis {
        case .one:
          PaceView(viewModel: viewModel)
          Spacer()
          
        case .two:
          MotivationView(viewModel: viewModel)
          Spacer()
        }
      }
    }
    .onAppear {
      Task{
        await viewModel.getAnalysis()
      }
    }
  }
}


struct PaceView: View {
  @ObservedObject var viewModel: AnalysisViewModel
  var body: some View {
    Text("How has your pace been affected by your menstrual cycle?")
      .font(.headline)
      .multilineTextAlignment(.center)
    PaceChart(viewModel: viewModel)
    ScrollView{
      ForEach(viewModel.phases, id: \.self) { phase in
        AnalysisCard(title: phase.phase, value: viewModel.getPaceStatString(phase: phase).string, avgValue: viewModel.getPaceValueString(value: phase.current_avg_pace), colour: .accentRed, isPeak: viewModel.getPaceStatString(phase: phase).isPeak)
          .padding(.horizontal, 16)
        
      }
    }
  }
}

struct MotivationView: View {
  @ObservedObject var viewModel: AnalysisViewModel
  var body: some View {
    Text("How motivated have you felt to work out during your most recent cycle?")
      .font(.headline)
      .multilineTextAlignment(.center)
    MotivationChart(viewModel: viewModel)
    ScrollView{
      ForEach(viewModel.phases, id: \.self) { phase in
        AnalysisCard(title: phase.phase, value: viewModel.getMotivationStatString(phase: phase).string, avgValue: viewModel.getMotivationValueString(value: phase.current_avg_motivation), colour: .accentgreen, isPeak: viewModel.getMotivationStatString(phase: phase).isPeak)
          .padding(.horizontal, 16)
        
      }
      
    }

  }
}

struct PaceChart: View {
  @ObservedObject var viewModel: AnalysisViewModel
  var body: some View {
    Chart(viewModel.phases) { phase in
        LineMark(
          x: .value("Day", phase.phase),
          y: .value("Amount", phase.current_avg_pace)
        )
        .foregroundStyle(.gray)
        PointMark(
            x: .value("Day", phase.phase),
            y: .value("Amount", phase.current_avg_pace)
        )
        .foregroundStyle(.accentRed)
        .symbolSize(60)
    }
    .chartXAxisLabel("Phase of Cycle")
    .chartYAxisLabel("Average Pace")
    .padding(.all , 16)
  }
}

struct MotivationChart: View{
  @ObservedObject var viewModel: AnalysisViewModel
  var body: some View {
    Chart(viewModel.phases) { phase in
        LineMark(
          x: .value("Day", phase.phase),
          y: .value("Amount", phase.current_avg_motivation)
        )
        .foregroundStyle(.gray)

        PointMark(
            x: .value("Day", phase.phase),
            y: .value("Amount", phase.current_avg_motivation)
        )
        .foregroundStyle(.accentgreen)
    }
    .chartXAxisLabel("Phase of Cycle")
    .chartYAxisLabel("Motivation Level")
    .padding(.all , 16)
  }
}

struct AnalysisPicker: View {
  @Binding var analysis: Analysis
      
    init(analysis: Binding<Analysis>) {
      self._analysis = analysis
        UISegmentedControl.appearance().setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.accentPurple)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().backgroundColor = .white
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("What view would you like", selection: $analysis) {
              ForEach(Analysis.allCases , id: \.self) {
                    Text("\($0.string.capitalized)")
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

enum Analysis: String, CaseIterable {
  case one // Pace
  case two // Mood
  
  var string: String{
    switch self {
    case .one:
      return "pace"
    case .two:
      return "mood"
    }
  }
  
  var intValue: Int{
    switch self{
    case .one:
      return 1
    case .two:
      return 2
    }
  }
}

struct AnalysisCard: View {
    let title: String
    let value: String
    let avgValue: String
    let colour: Color
    let isPeak: Bool?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(colour)
              Text(avgValue)
                  .font(.system(size: 16, weight: .bold))
                  .foregroundColor(colour)
                
                Spacer()
                
              if isPeak ?? false {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("Peak")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(colour))
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(colour)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isPeak ?? false ? colour.opacity(0.3) : colour.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
              .stroke(isPeak ?? false ? colour : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
  AnalysisCard(title: "Menstrual", value: "Mood may dip; prioritise rest and recovery.", avgValue: "4.5/km", colour: .accentgreen, isPeak: true)
}

