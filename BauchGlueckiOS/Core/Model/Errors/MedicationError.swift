//
//  MedicationError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum MedicationError: Error, LocalizedError {
    case notLoggedIn

    var errorDescription: String? {
        switch self {
            case .notLoggedIn: return "⚠️ Du bist nicht eingeloggt."
        }
    }
}
