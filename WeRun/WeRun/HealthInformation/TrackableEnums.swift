//
//  TrackableEnums.swift
//  WeRun
//
//  Created by Aimee Daly on 25/02/2026.
//

enum EnergyLevel: Int, CaseIterable {
    case exhausted = 0
    case tired
    case ok
    case energised
    case fullyEnergised
    
    var label: String {
        switch self {
        case .exhausted: return "Exhausted"
        case .tired: return "Tired"
        case .ok: return "OK"
        case .energised: return "Energised"
        case .fullyEnergised: return "Fully Energised"
        }
    }
}

enum UrineColour: Int, CaseIterable {
    case clear = 0
    case yellow
    case dark
    
    var label: String {
        switch self {
        case .clear: return "Clear"
        case .yellow: return "Yellow"
        case .dark: return "Dark"
        }
    }
}

enum MuscleSoreness: Int, CaseIterable {
    case stiff = 0
    case okay
    case heavy
    
    var label: String {
        switch self {
        case .stiff: return "Stiff"
        case .okay: return "Okay"
        case .heavy: return "Heavy"
        }
    }
}

enum SweatLevel: Int, CaseIterable {
    case not = 0
    case mild
    case more
    
    var label: String {
        switch self {
        case .not: return "Not sweating"
        case .mild: return "Mild Sweating"
        case .more: return "More then Normal"
        }
    }
}

enum AnxietyLevel: Int, CaseIterable {
    case not = 0
    case mild
    case more
    
    var label: String {
        switch self {
        case .not: return "Not Anxious"
        case .mild: return "Mild Anxiety"
        case .more: return "More Anxious then normal"
        }
    }
}

