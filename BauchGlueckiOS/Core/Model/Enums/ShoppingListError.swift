//
//  ShoppingListError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//

import Foundation

enum ShoppingListError: Error, LocalizedError {
    case noMealPlansFound
    case noIngredientsFound
    case invalidDateRange
    case insertFailed
    case noUserFound
    
    var errorDescription: String? {
        switch self {
        case .noUserFound: return NSLocalizedString("Es wurde kein Benutzer gefunden.", comment: "Kein Benutzer Fehler")
        case .noMealPlansFound: return NSLocalizedString("Es wurden keine Essenspläne im angegebenen Zeitraum gefunden.", comment: "Keine Essenspläne Fehler")
        case .noIngredientsFound: return NSLocalizedString("Die geladenen Essenspläne enthalten keine Zutaten.", comment: "Keine Zutaten Fehler")
        case .invalidDateRange: return NSLocalizedString("Der angegebene Zeitraum ist ungültig.", comment: "Ungültiger Zeitraum Fehler")
        case .insertFailed: return NSLocalizedString("Es trat ein Fehler beim Einfügen der Daten auf.", comment: "Einfügen Fehler")
        }
    }
}
