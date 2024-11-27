//
//  DayItem.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI

struct DayItem: View {
    @Environment(\.theme) private var theme
    var date: Date
    var selectedDate: Date
    var currentMealCount: Int
    var targetMealCount: Int
    var onTab: (Date) -> Void
    
    private var isToday: Bool {
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 4) { 
            
            HeadLineText(DateFormatteUtil.formatDateDDMM(date))
             
            FootLineText("\(currentMealCount)/\(targetMealCount)")
        }
        .frame(width: 80, height: 80)
        .sectionShadow()
        .overlay(
            RoundedRectangle(cornerRadius: theme.layout.radius)
                .stroke(theme.color.primary, lineWidth: isToday ? 1 : 0)
                .animation(.easeInOut, value: isToday)
        )
        .onTapGesture { onTab(date) }
    }
}
