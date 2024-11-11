//
//  DateService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

class DateService { 
    
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static var today = Date()
    static var currentTimeStamp = Date().timeIntervalSince1970Milliseconds

    static var startToday = Calendar.current.startOfDay(for: Date())
    static var endOfDAy: Date {
        let cal = Calendar.current
        let tomorrowStart = cal.date(byAdding: .day, value: 1, to: self.startToday)!
        return cal.date(byAdding: .second, value: -1, to: tomorrowStart)!
    }
    
    static var nextThirtyDays: [Date] {
        let cal = Calendar.current
        let today = Date()
        
        var dates: [Date] = []
        
        for i in 0..<30 {
            let date = cal.date(byAdding: .day, value: i, to: today)!
            dates.append(date)
        }
        
        return dates
    }
    
    static var lastSixteenWeeks: [[Date]] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        var weeks: [[Date]] = []
        
        if let endOfThisWeek = calendar.nextWeekend(startingAfter: Date())?.end {
            var currentDate = endOfThisWeek
         
            for _ in 0..<16 {
                var week: [Date] = []
                
                for dayOffset in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: currentDate) {
                        week.insert(date, at: 0)
                    }
                }
                
                weeks.insert(week, at: 0)
                currentDate = calendar.date(byAdding: .day, value: -7, to: currentDate)!
            }
        }
        
        return weeks
    }
    
    static func formatTimeToHHmm(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "de_DE")
        return dateFormatter.string(from: date)
    }
    
    static func formatDateDDMM(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        dateFormatter.locale = Locale(identifier: "de_DE")
        return dateFormatter.string(from: date)
    }
}

extension Date {
    func startOfDate() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        let cal = Calendar.current
        let tomorrowStart = cal.date(byAdding: .day, value: 1, to: self)!
        return cal.date(byAdding: .second, value: -1, to: tomorrowStart)!
    }
}
