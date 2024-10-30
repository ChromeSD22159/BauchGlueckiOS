//
//  WeightChart.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI
import SwiftData

struct WeightChart: View {
    @Query() var weights: [Weight]
    
    var onClick: () -> Void
    
    var hasValidData = false
    
    var weeklyAverage: [WeeklyAverage]
    
    var body: some View {
        if (hasValidData) {
            HomeWeightCard(weeklyAverage: weeklyAverage)
                .onTapGesture {
                    onClick()
                }
       } else {
           HomeWeightMockCard()
               .onTapGesture {
                   onClick()
               }
       }
    }
}

struct HomeWeightCard: View {
    let theme: Theme = Theme.shared
    var weeklyAverage: [WeeklyAverage]
    
    var gradient = LinearGradient(colors: [
        Theme.shared.primary.opacity(0.55),
        Theme.shared.primary.opacity(0.1)
    ], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack {
            
        }
    }
}
