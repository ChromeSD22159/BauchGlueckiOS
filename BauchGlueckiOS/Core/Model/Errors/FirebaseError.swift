//
//  FirebaseError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 25.11.24.
//

import Foundation
 
enum FirebaseError: Error, LocalizedError, ErrorDescriptionProtocol {
    case userNotFound
    case userEmailNotFound
    case googleAuthFailure
    case appleAuthFailure
    case noAPNSToken
    case invalidCredential
    case networkError
    case tooManyRequests
    case internalError
    case tokenExpired
    case insufficientPermissions
    case userDisabled
    case emailAlreadyInUse
    case weakPassword
    case operationNotAllowed
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "⚠️ Benutzer nicht gefunden. Bitte überprüfen Sie Ihre Anmeldedaten oder registrieren Sie sich, falls Sie noch kein Konto haben."
        case .userEmailNotFound:
            return "⚠️ E-Mail-Adresse nicht gefunden. Bitte stellen Sie sicher, dass Sie die richtige E-Mail-Adresse eingegeben haben."
        case .googleAuthFailure:
            return "⚠️ Fehler bei der Anmeldung mit Google. Bitte versuchen Sie es erneut."
        case .appleAuthFailure:
            return "⚠️ Fehler bei der Anmeldung mit Apple. Bitte versuchen Sie es erneut."
        case .noAPNSToken:
            return "⚠️ APNS-Token konnte nicht abgerufen werden. Push-Benachrichtigungen funktionieren möglicherweise nicht."
        case .invalidCredential:
            return "⚠️ Ungültige Anmeldedaten. Bitte überprüfen Sie Ihre Login-Informationen."
        case .networkError:
            return "⚠️ Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut."
        case .tooManyRequests:
            return "⚠️ Zu viele Anfragen. Bitte warten Sie einen Moment, bevor Sie es erneut versuchen."
        case .internalError:
            return "⚠️ Ein interner Fehler ist aufgetreten. Bitte versuchen Sie es später erneut."
        case .tokenExpired:
            return "⚠️ Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an."
        case .insufficientPermissions:
            return "⚠️ Sie haben nicht die erforderlichen Berechtigungen, um diese Aktion auszuführen."
        case .userDisabled:
            return "⚠️ Dieses Konto wurde deaktiviert. Bitte wenden Sie sich an den Support, um Hilfe zu erhalten."
        case .emailAlreadyInUse:
            return "⚠️ Diese E-Mail-Adresse wird bereits verwendet. Bitte nutzen Sie eine andere E-Mail-Adresse oder melden Sie sich an."
        case .weakPassword:
            return "⚠️ Das eingegebene Passwort ist zu schwach. Bitte wählen Sie ein stärkeres Passwort."
        case .operationNotAllowed:
            return "⚠️ Diese Aktion ist nicht erlaubt. Bitte wenden Sie sich an den Support, um Hilfe zu erhalten."
        case .unknownError(let message):
            return "⚠️ Ein unbekannter Fehler ist aufgetreten: \(message)"
        }
    }
}

