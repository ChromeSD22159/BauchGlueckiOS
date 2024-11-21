//
//  NoteError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum NoteError: Error, LocalizedError {
    case notLoggedIn
    case invalidText
    case noteNotFound

    var errorDescription: String? {
        switch self {
            case .notLoggedIn: return "⚠️ Du bist nicht eingeloggt."
            case .invalidText: return "⚠️ Der Text muss mindestens 5 Buchstaben beinhalten."
            case .noteNotFound: return "⚠️ Die Notiz wurde nicht gefunden."
        }
    }
}
