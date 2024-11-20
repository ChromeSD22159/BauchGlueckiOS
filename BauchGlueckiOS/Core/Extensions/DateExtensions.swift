//
//  DateExtensions.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//
import SwiftUI

extension Date {
    /// Returns the current timestamp in milliseconds since 1970.
    ///
    /// - Returns: A 64-bit integer representing the current timestamp in milliseconds.
    var timeIntervalSince1970Milliseconds: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    /// Returns a new date representing the beginning of the current day (12:00 AM).
    /// - Returns: A new `Date` object set to the start of the current day.
    func startOfDate() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Returns a new date representing the end of the current day (11:59 PM).
    /// - Returns: A new `Date` object set to the end of the current day.
    func endOfDay() -> Date {
        let calendar = Calendar.current
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: self)!
        return calendar.date(byAdding: .second, value: -1, to: tomorrowStart)!
    }

    /// Gets a formatted string representing the time in "HH:mm" format (e.g., "15:30").
    /// - Returns: A string representation of the time in "HH:mm" format.
    var formatTimeToHHmm: String {
        return DateFormatteUtil.formatTimeToHHmm(self)
    }

    /// Gets a formatted string representing the date in "dd.MM" format (e.g., "25.12").
    /// - Returns: A string representation of the date in "dd.MM" format.
    var formatDateDDMM: String {
        return DateFormatteUtil.formatDateDDMM(self) // This should be formatDateDDMM
    }
}

extension Int64 {
    /// Converts the Int64 timestamp (in milliseconds) to a `Date` object.
    ///
    /// - Returns: A `Date` object representing the given timestamp.
    var toDate: Date {
        return Date(timeIntervalSince1970: Double(self / 1000))
    }
}
