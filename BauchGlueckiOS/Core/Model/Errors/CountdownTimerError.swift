//
//  CountdownTimerError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum CountdownTimerError: Error, LocalizedError, ErrorDescriptionProtocol {
    case emailIsEmpty

    var errorDescription: String? {
        switch self {
        case .emailIsEmpty: return "⚠️ Die E-Mail-Adresse darf nicht leer sein."
        }
    }
}
