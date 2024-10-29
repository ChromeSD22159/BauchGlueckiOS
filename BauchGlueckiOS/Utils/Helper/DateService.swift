//
//  DateService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

class DateService {
    static var today = Date()
    static var currentTimeStamp = Date().timeIntervalSince1970Milliseconds

    static var startToday = Calendar.current.startOfDay(for: Date())
    static var endOfDAy: Date {
        let cal = Calendar.current
        let tomorrowStart = cal.date(byAdding: .day, value: 1, to: self.startToday)!
        return cal.date(byAdding: .second, value: -1, to: tomorrowStart)!
    }
}
