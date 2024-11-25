//
//  WeightError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum WeightError: Error, LocalizedError, ErrorDescriptionProtocol {
    case emailIsEmpty
    case invalidWeight
    case userNotFound
    
    var errorDescription: String? {
        switch self {
            case .emailIsEmpty: return "⚠️ Die E-Mail-Adresse darf nicht leer sein."
            case .invalidWeight: return "⚠️ Der Name muss mindestens 3 Buchstaben beinhalten."
            case .userNotFound: return "⚠️ Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
        }
    }
}

protocol ErrorDescriptionProtocol {
    var errorDescription: String? { get }
}
