//
//  RegisterError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum RegisterError: Error, LocalizedError, ErrorDescriptionProtocol {
    case emailIsEmpty
    case passwordIsEmpty
    case verifyPasswordIsEmpty
    case passwordsDoNotMatch
    case emailInvalid
    case passwordTooWeak

    var errorDescription: String? {
        switch self {
        case .emailIsEmpty: return "⚠️ Die E-Mail-Adresse darf nicht leer sein."
        case .passwordIsEmpty: return "⚠️ Das Passwort darf nicht leer sein."
        case .verifyPasswordIsEmpty: return "⚠️ Das Bestätigungspasswort darf nicht leer sein."
        case .passwordsDoNotMatch: return "⚠️ Die Passwörter stimmen nicht überein."
        case .emailInvalid: return "⚠️ Die E-Mail-Adresse ist ungültig."
        case .passwordTooWeak: return "⚠️ Das Passwort ist zu schwach. Bitte verwenden Sie mindestens 6 Zeichen, inklusive Großbuchstaben, Kleinbuchstaben und Zahlen."
        }
    }
}
