//
//  LoginError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//

import Foundation

enum LoginError: Error, LocalizedError {
    case emailIsEmpty
    case passwordIsEmpty
    case signInFailed

    var errorDescription: String? {
        switch self {
            case .emailIsEmpty: return "⚠️ Die E-Mail-Adresse darf nicht leer sein."
            case .passwordIsEmpty: return "⚠️ Das Passwort darf nicht leer sein."
            case .signInFailed: return "⚠️ SignIn fehlgeschlagen, bitte prüfen Sie Ihre Eingaben."
        }
    }
}


