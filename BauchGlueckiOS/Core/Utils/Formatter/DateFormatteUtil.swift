//
//  DateFormatteUtil.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//
import Foundation

struct DateFormatteUtil {
    /// Formats a date into a German "dd.MM" string.
    /// - Parameter date: The date to format.
    /// - Returns: A string in the format "dd.MM", e.g., "25.12".
    static func formatDateDDMM(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        dateFormatter.locale = Locale(identifier: "de_DE")
        return dateFormatter.string(from: date)
    }

    /// Formats a date into a German "HH:mm" time string.
    /// - Parameter date: The date to format.
    /// - Returns: A string in the format "HH:mm", e.g., "15:30".
    static func formatTimeToHHmm(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "de_DE")
        return dateFormatter.string(from: date)
    }

    /// Creates a string representing a date range in German format.
    /// - Parameter from: The start date.
    /// - Parameter till: The end date.
    /// - Returns: A string in the format "From: dd.MM to dd.MM:", e.g., "From: 25.12 to 31.12:".
    static func fromTillString(from: Date, till: Date) -> String {
        return "From: \(from.formatDateDDMM) to \(till.formatDateDDMM):"
    }
    
    /// Formats a date into a readable German date and time format.
    ///
    /// This function optionally accepts a `Date` object. If no date is passed,
    /// the current date is used. The formatted date is returned as a string.
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A string representing the date in the format "dd.MM.yyyy HH:mm".
    static func formattedDateTimer(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return formatter.string(from: date)
    }
    
    /// Formats a date into a readable German date format (without time).
    ///
    /// This function optionally accepts a `Date` object. If no date is passed,
    /// the current date is used. The formatted date is returned as a string.
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A string representing the date in the format "dd.MM.yyyy".
    static func formattedFullDate(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy"
        
        return formatter.string(from: date)
    }
}
