//
//  UserProfile.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

import Foundation

struct UserProfile: Codable {
    var uid: String? = nil
    var firstName: String = ""
    var email: String = ""
    var surgeryDateTimeStamp: TimeInterval = Date().timeIntervalSince1970 * 1000
    var mainMeals: Int = 3
    var betweenMeals: Int = 3
    var profileImageURL: String? = nil
    var startWeight: Double = 100.0
    var waterIntake: Double = 0.25
    var waterDayIntake: Double = 2.0
    var userNotifierToken: String = ""
    var role: UserRole? = .user

    // Computed property to convert timestamp to Date
    var surgeryDate: Date {
        get {
            return Date(timeIntervalSince1970: surgeryDateTimeStamp / 1000)
        }
        set {
            surgeryDateTimeStamp = newValue.timeIntervalSince1970 * 1000
        }
    }
    
    // Computed property to calculate total meals
    var totalMeals: Int {
        get {
            return mainMeals + betweenMeals
        }
        set {
            mainMeals = newValue - betweenMeals
        }
    }

    // Functions to update surgery date
    mutating func updateSurgeryDate(newDate: Date) {
        surgeryDateTimeStamp = newDate.timeIntervalSince1970 * 1000
    }

    mutating func updateSurgeryDate(newDateLong: TimeInterval) {
        surgeryDateTimeStamp = newDateLong
    }
}

// Enum for user roles
enum UserRole: String, Codable {
    case user
    case admin
}
