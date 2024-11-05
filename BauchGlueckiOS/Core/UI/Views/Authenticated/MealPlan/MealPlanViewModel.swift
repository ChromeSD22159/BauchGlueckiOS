//
//  MealPlanViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI

@Observable
class MealPlanViewModel {
    var currentDate: Date = Date()
    
    var dates: [Date] {
        let cal = Calendar.current
        let today = Date()
        
        var dates: [Date] = []
        
        for i in 0..<30 {
            let date = cal.date(byAdding: .day, value: i, to: today)!
            dates.append(date)
        }
        
        return dates
     }
    
    func setCurrentDate(date: Date) {
        currentDate = date
    }
}
