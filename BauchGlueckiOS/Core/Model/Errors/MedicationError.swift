//
//  MedicationError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum MedicationError: Error, LocalizedError, ErrorDescriptionProtocol {
    case invalidName
    case invalidDosis
    case userNotFound
    case medikationExist
    
    var errorDescription: String? {
        switch self {
            case .invalidName: return "⚠️ Der Name muss mindestens 3 Buchstaben beinhalten."
            case .invalidDosis: return "⚠️ Die Dosis sollte nicht leer sein."
            case .userNotFound: return "⚠️ Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
            case .medikationExist: return "⚠️ Ein Medikament mit dem Namen existiert bereits."
        }
    }
} 
