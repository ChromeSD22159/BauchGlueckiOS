//
//  WeightFormatUtils.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

import Foundation

struct WeightFormatUtils {
    
    /// Formatiert ein Double als Gewicht mit einer Nachkommastelle und dem Suffix "kg".
    /// - Parameter value: Der zu formatierende Wert.
    /// - Returns: Der formatierte String, z. B. "75.3 kg".
    static func formatWeight(_ value: Double) -> String {
        return String(format: "%.1f kg", value)
    }
    
    /// Formatiert ein Double als Differenz mit einer Nachkommastelle und einem optionalen Vorzeichen.
    /// - Parameter difference: Der zu formatierende Wert.
    /// - Returns: Der formatierte String, z. B. "+2.3 kg" oder "-1.5 kg".
    static func formatWeightDifference(_ difference: Double) -> String {
        if difference >= 0 {
            return String(format: "+%.1f kg", difference)
        } else {
            return String(format: "%.1f kg", difference)
        }
    }
    
    /// Formatiert zwei Datumswerte in einen String im Format "Von: DD.MM zu DD.MM".
    /// - Parameters:
    ///   - from: Das Startdatum des Zeitraums.
    ///   - till: Das Enddatum des Zeitraums.
    /// - Returns: Ein String im Format "Von: DD.MM zu DD.MM", der den Zeitraum repräsentiert.
    static func fromTillDateString(from: Date, till: Date) -> String {
        let from = DateService.formatDateDDMM(date: from)
        let till = DateService.formatDateDDMM(date: till)
        return String(format: "Von: \(from) zu \(till)")
    }
}
