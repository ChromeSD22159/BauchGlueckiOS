//
//  MealPlanError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum MealPlanError: Error, LocalizedError, ErrorDescriptionProtocol {
    case notLoggedIn

    var errorDescription: String? {
        switch self {
            case .notLoggedIn: return "⚠️ Du bist nicht eingeloggt."
        }
    }
}
