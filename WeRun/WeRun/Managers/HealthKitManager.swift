//
//  HealthKitManager.swift
//  WeRun
//
//  Created by Aimee Daly on 25/11/2025.
//

import HealthKit
import Foundation

enum LoadState {
    case idle
    case loading
    case loaded
    case error(Error)
    case notAuthorized
}

enum Symptoms: String, CaseIterable {
  case abdominalCramps
  case acne
  case bloating
  case breastPain
  case lowerBackPain
  case fatigue
  case diarrhoea
  case chills
  case nausea
  
  var displayName: String {
    switch self {
    case .abdominalCramps:
      return "Abdominal Cramps"
    case .acne:
      return "Acne"
    case .bloating:
      return "Bloating"
    case .breastPain:
      return "Breast Pain"
    case .lowerBackPain:
      return "Lower Back Pain"
    case .fatigue:
      return "Fatigue"
    case .diarrhoea:
      return "Diarrhoea"
    case .chills:
      return "Chills"
    case .nausea:
      return "Nausea"
    }
  }
    
    var identifier: HKCategoryTypeIdentifier{
      switch self{
      case .abdominalCramps:
        return .abdominalCramps
      case .acne:
        return .acne
      case .bloating:
        return .bloating
      case .breastPain:
        return .breastPain
      case .lowerBackPain:
        return .lowerBackPain
      case .fatigue:
        return .fatigue
      case .diarrhoea:
        return .diarrhea
      case .chills:
        return .chills
      case .nausea:
        return .nausea
      }
    }
}


struct MenstrualCycle: Hashable {
    let startDate: Date   // period start date
    let endDate: Date     // period end date
    let lengthInDays: Int // period length
    //let flowSamples: [HKCategorySample]
}


@MainActor
class HealthKitManager: ObservableObject{
  
  // 1.
  static let shared = HealthKitManager()
  private let healthStore = HKHealthStore()
  @Published var workoutHistory: [HKWorkout] = []
  
  private init() {}
  
  // 2.
  func requestAuthorization() async throws -> Bool {
    // Ensure HealthKit is available on this device
    guard HKHealthStore.isHealthDataAvailable() else { return false }
     
    // Define the types we want to read
    let readTypes: Set<HKObjectType> = [
      HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
      HKObjectType.categoryType(forIdentifier: .abdominalCramps)!,
      HKObjectType.categoryType(forIdentifier: .acne)!,
      HKObjectType.categoryType(forIdentifier: .bloating)!,
      HKObjectType.categoryType(forIdentifier: .breastPain)!,
      HKObjectType.categoryType(forIdentifier: .lowerBackPain)!,
      HKObjectType.categoryType(forIdentifier: .fatigue)!,
      HKObjectType.categoryType(forIdentifier: .diarrhea)!,
      HKObjectType.categoryType(forIdentifier: .chills)!,
      HKObjectType.categoryType(forIdentifier: .nausea)!,
      HKObjectType.workoutType(),
      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
      HKObjectType.quantityType(forIdentifier: .heartRate)!

    ]
    
    let writeTypes: Set<HKSampleType> = [
      HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
      HKObjectType.categoryType(forIdentifier: .abdominalCramps)!,
      HKObjectType.categoryType(forIdentifier: .acne)!,
      HKObjectType.categoryType(forIdentifier: .bloating)!,
      HKObjectType.categoryType(forIdentifier: .breastPain)!,
      HKObjectType.categoryType(forIdentifier: .lowerBackPain)!,
      HKObjectType.categoryType(forIdentifier: .fatigue)!,
      HKObjectType.categoryType(forIdentifier: .diarrhea)!,
      HKObjectType.categoryType(forIdentifier: .chills)!,
      HKObjectType.categoryType(forIdentifier: .nausea)!,
      HKObjectType.workoutType(),
      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    return try await withCheckedThrowingContinuation { continuation in
      healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: success)
        }
      }
    }
  }
  // 3.
  
  func fetchMenstrualFlowData() async throws -> [HKCategorySample]? {
      guard let menstrualFlowType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
          print("Menstrual flow type is not available")
          return nil
      }

      let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
      let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

      return try await withCheckedThrowingContinuation { continuation in
          let query = HKSampleQuery(sampleType: menstrualFlowType,
                                    predicate: predicate,
                                    limit: HKObjectQueryNoLimit,
                                    sortDescriptors: nil) { _, samples, error in
              if let error = error {
                  continuation.resume(throwing: error)
                  return
              }

              if let samples = samples as? [HKCategorySample] {
                  continuation.resume(returning: samples)
              } else {
                  continuation.resume(returning: nil)
              }
          }

          healthStore.execute(query)
      }
  }
  
  func saveMenstrualFlow(flow: Int, start: Date, end: Date) {
      guard let type = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
          return
      }
    
    let metaData: [String: Any] = [
      HKMetadataKeyMenstrualCycleStart: true
    ]
      
      let sample = HKCategorySample(type: type,
                                    value: flow,
                                    start: start,
                                    end: end,
                                    metadata: metaData)
      
      healthStore.save(sample) { success, error in
          if success {
              print("Saved menstrual flow sample")
          } else {
              print("Error: \(String(describing: error))")
          }
      }
  }
  
  func saveSymptom(_ symptom: Symptoms) {
    guard let type = HKObjectType.categoryType(forIdentifier: symptom.identifier) else {
      return
    }
    
    
    let sample = HKCategorySample(
        type: type,
        value: HKCategoryValue.notApplicable.rawValue, // for symptoms
        start: Date(),
        end: Date()
    )

    
    healthStore.save(sample) { success, error in
        if success {
          print("Saved \(symptom.displayName) sample (\(success))")
        } else {
            print("Error: \(String(describing: error))")
        }
    }


    

  }
  
  func fetchLastNCycles(_ count: Int) async throws -> [MenstrualCycle] {
      guard let menstrualFlowType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
          throw NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Menstrual flow type not available"])
      }

      // Fetch enough data to cover multiple cycles (e.g. 12 months back)
      let startDate = Calendar.current.date(byAdding: .month, value: -12, to: Date())
      let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

      let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCategorySample], Error>) in
          let query = HKSampleQuery(sampleType: menstrualFlowType,
                                    predicate: predicate,
                                    limit: HKObjectQueryNoLimit,
                                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, results, error in
              if let error = error {
                  continuation.resume(throwing: error)
                  return
              }
              continuation.resume(returning: results as? [HKCategorySample] ?? [])
          }

          healthStore.execute(query)
      }

      // --- Group samples into cycles ---
      var cycles: [MenstrualCycle] = []
      var currentCycle: [HKCategorySample] = []

      for sample in samples {
          if currentCycle.isEmpty {
              // Start new cycle
              currentCycle.append(sample)
          } else {
              if isNewPeriodStart(sample, comparedTo: currentCycle.last) {
                  // Close out previous cycle
                  if let cycle = buildCycle(from: currentCycle) {
                      cycles.append(cycle)
                  }
                  // Start a new one
                  currentCycle = [sample]
              } else {
                  currentCycle.append(sample)
              }
          }
      }

      // Append last cycle
      if let cycle = buildCycle(from: currentCycle) {
          cycles.append(cycle)
      }

      return Array(cycles.suffix(count))
  }
  
  /// Decide if a sample marks the start of a new cycle
  private func isNewPeriodStart(_ sample: HKCategorySample, comparedTo previous: HKCategorySample?) -> Bool {
      guard let previous = previous else { return false }

      // Gap > 10 days between samples = new cycle (tweak this if needed)
      let gap = Calendar.current.dateComponents([.day], from: previous.endDate, to: sample.startDate).day ?? 0
      return gap > 10
  }
  
  // 3.
  func fetchMostRecentCategoryType(for identifier: HKCategoryTypeIdentifier) async throws -> HKQuantitySample? {
      // Get the quantity type for the identifier
    guard let categoryType = HKObjectType.categoryType(forIdentifier: identifier) else {
          return nil
      }

      // Query for samples from start of today until now, sorted by end date descending
      let predicate = HKQuery.predicateForSamples(
          withStart: Calendar.current.startOfDay(for: Date()),
          end: Date(),
          options: .strictStartDate
      )
      let sortDescriptor = NSSortDescriptor(
          key: HKSampleSortIdentifierEndDate,
          ascending: false
      )

      return try await withCheckedThrowingContinuation { continuation in
          let query = HKSampleQuery(
              sampleType: categoryType,
              predicate: predicate,
              limit: 1,
              sortDescriptors: [sortDescriptor]
          ) { _, samples, error in
              if let error = error {
                  continuation.resume(throwing: error)
              } else {
                  continuation.resume(returning: samples?.first as? HKQuantitySample)
              }
          }
          healthStore.execute(query)
      }
  }

  /// Convert flow samples into a MenstrualCycle struct
  private func buildCycle(from samples: [HKCategorySample]) -> MenstrualCycle? {
      guard let first = samples.first, let last = samples.last else { return nil }

      let length = Calendar.current.dateComponents([.day], from: first.startDate, to: last.endDate).day ?? 0

      return MenstrualCycle(
          startDate: first.startDate,
          endDate: last.endDate,
          lengthInDays: length
          //flowSamples: samples
      )
  }
  
  func saveWorkout(distance: Double, duration: TimeInterval, calories: Double, startDate: Date, completion: @escaping (Bool) -> Void) {
      let workout = HKWorkout(
          activityType: .running,
          start: startDate,
          end: Date(),
          duration: duration,
          totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
          totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
          metadata: nil
      )
      
      healthStore.save(workout) { success, error in
          DispatchQueue.main.async {
              completion(success)
          }
      }
  }
  
  // Fetch workouts for a specific date
  func fetchWorkouts(for date: Date, completion: @escaping ([HKWorkout]) -> Void) {
      let calendar = Calendar.current
      let startOfDay = calendar.startOfDay(for: date)
      let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
      
      let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
      let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
      let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, workoutPredicate])
      
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
      
      let query = HKSampleQuery(sampleType: .workoutType(), predicate: compoundPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
          guard let workouts = samples as? [HKWorkout], error == nil else {
              DispatchQueue.main.async {
                  completion([])
              }
              return
          }
          
          DispatchQueue.main.async {
              completion(workouts)
          }
      }
      
      healthStore.execute(query)
  }
  
  func fetchAllRunningWorkouts(completion: @escaping ([HKWorkout]) -> Void) {
      let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
      
      let query = HKSampleQuery(sampleType: .workoutType(), predicate: workoutPredicate, limit: 50, sortDescriptors: [sortDescriptor]) { _, samples, error in
          guard let workouts = samples as? [HKWorkout], error == nil else {
              DispatchQueue.main.async {
                  completion([])
              }
              return
          }
          
          DispatchQueue.main.async {
              self.workoutHistory = workouts
              completion(workouts)
          }
      }
      
      healthStore.execute(query)
  }



  

  
}

