//
//  WorkoutManager.swift
//  WeRun
//
//  Created by Aimee Daly on 26/11/2025.
//

import Foundation
import SwiftUI
import HealthKit
import CoreLocation

class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var distance: Double = 0.0 // meters
    @Published var duration: TimeInterval = 0.0
    @Published var calories: Double = 0.0
    @Published var pace: Double = 0.0 // min/km
    @Published var currentSpeed: Double = 0.0 // m/s
    static let shared = WorkoutManager()
    
    private var timer: Timer?
    private var startDate: Date?
    private var pausedTime: TimeInterval = 0.0
    private var lastPauseDate: Date?
    
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
    }
  

    
  func requestLocationPermission() -> Bool {
        locationManager.requestWhenInUseAuthorization()
        return true
    }
    
    func startWorkout() {
        isRunning = true
        isPaused = false
        startDate = Date()
        distance = 0.0
        duration = 0.0
        calories = 0.0
        pace = 0.0
        pausedTime = 0.0
        lastLocation = nil
        
        locationManager.startUpdatingLocation()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.duration += 1.0
            self.updateStats()
        }
    }
    
    func pauseWorkout() {
        isPaused = true
        lastPauseDate = Date()
        locationManager.stopUpdatingLocation()
    }
    
    func resumeWorkout() {
        isPaused = false
        if let lastPauseDate = lastPauseDate {
            pausedTime += Date().timeIntervalSince(lastPauseDate)
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopWorkout() -> (distance: Double, duration: TimeInterval, calories: Double, startDate: Date) {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        
        let workoutData = (
            distance: distance,
            duration: duration,
            calories: calories,
            startDate: startDate ?? Date()
        )
        
        return workoutData
    }
    
    private func updateStats() {
        // Calculate calories (rough estimate: 1 cal per kg per km)
        let distanceKm = distance / 1000.0
        calories = distanceKm * 70.0 // Assuming 70kg runner
        
        // Calculate pace (min/km)
        if duration > 0 && distance > 0 {
            pace = (duration / 60.0) / (distance / 1000.0)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !isPaused else { return }
        
        // More lenient filtering for better tracking
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 65 {
            return // Skip very inaccurate readings
        }
        
        if let lastLocation = lastLocation {
            let distanceIncrement = location.distance(from: lastLocation)
            let timeDifference = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            
            // Filter out readings that are too close in time or suspiciously far
            if timeDifference > 0.5 && distanceIncrement < 150 {
                distance += distanceIncrement
                currentSpeed = location.speed > 0 ? location.speed : 0
                
                // Debug: Uncomment to see distance updates
                print("Distance increment: \(distanceIncrement)m, Total: \(distance)m, Accuracy: \(location.horizontalAccuracy)m")
            }
        } else {
            // First location
            print("First location acquired with accuracy: \(location.horizontalAccuracy)m")
        }
        
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
