//
//  KcalLe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//

enum KcalLevel {
    case junior, mid, senior
    
    var kcal: Int {
        switch self {
            case .junior: 800
            case .mid: 1000
            case .senior: 1200
        }
    }
    
    var protein: Int {
        switch self {
            case .junior: return 60
            case .mid: return 80
            case .senior: return 100
        }
    }

    var fat: Int {
        switch self {
            case .junior: return 30
            case .mid: return 40
            case .senior: return 50
        }
    }

    var sugar: Int {
        switch self {
            case .junior: return 20
            case .mid: return 25
            case .senior: return 30
        }
    }
    
    var carbs: Int {
        switch self {
            case .junior: return 90
            case .mid: return 150
            case .senior: return 250
        }
    }
}
