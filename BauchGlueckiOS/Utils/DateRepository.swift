//
//  DateRepository.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import Foundation

class DateRepository {
    let calendar = Calendar.current
    
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static var today: Date = Date()
    
    var lastSixteenWeeks: [[Date]] {
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
}
