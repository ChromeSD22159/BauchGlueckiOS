//
//  DateService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
 
struct DateHelper {

    /// Returns the date for yesterday.
    /// - Returns: A `Date` object representing yesterday.
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }

    /// Returns the current date.
    /// - Returns: A `Date` object representing the current date.
    static var today: Date = Date()

    /// Returns the current timestamp in milliseconds since 1970.
    /// - Returns: A `Double` representing the current timestamp in milliseconds since 1970.
    static var currentTimeStamp: Int64 {
        return Date().timeIntervalSince1970Milliseconds
    }

    /// Returns the start of the current day (12:00 AM).
    /// - Returns: A `Date` object set to the start of the current day.
    static var startToday: Date {
        return Calendar.current.startOfDay(for: Date())
    }

    /// Returns the end of the current day (11:59 PM).
    /// - Returns: A `Date` object set to the end of the current day.
    static var endOfDay: Date {
        let calendar = Calendar.current
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: startToday)!
        return calendar.date(byAdding: .second, value: -1, to: tomorrowStart)!
    }

    /// Returns an array containing the next 30 days, including today.
    /// - Returns: An array of `Date` objects representing the next 30 days.
    static var nextThirtyDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []

        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: i, to: today)!
            dates.append(date)
        }

        return dates
    }

    /// Returns an array containing the last 16 weeks (including the current week).
    /// - Returns: A 2D array of `Date` objects, where each inner array represents a week.
    static var lastSixteenWeeks: [[Date]] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Set Sunday as the first day of the week

        var weeks: [[Date]] = []

        if let endOfThisWeek = calendar.nextWeekend(startingAfter: Date())?.end {
            var currentDate = endOfThisWeek

            for _ in 0..<16 {
                var week: [Date] = []

                for dayOffset in 0..<7 { // Iterate through days in a week (Sunday to Saturday)
                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: currentDate) {
                        week.insert(date, at: 0) // Insert dates in reverse chronological order (Sunday first)
                    }
                }

                weeks.insert(week, at: 0) // Prepend weeks to maintain chronological order (most recent first)
                currentDate = calendar.date(byAdding: .day, value: -7, to: currentDate)! // Move to the previous week
            }
        }

        return weeks
    }
} 
