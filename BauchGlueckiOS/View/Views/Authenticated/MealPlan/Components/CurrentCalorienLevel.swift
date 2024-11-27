//
//  CurrentCalorienLevel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI

struct CurrentCalorienLevel: View {
    @Environment(\.theme) private var theme
    let operationTimestamp: Int64
    let calcedLevel: KcalLevel
    
    let protein: Int
    let carbs: Int
    let sugar: Int
    let fat: Int
    
    init(
        operationTimestamp: Int64,
        protein: Int,
        carbs: Int,
        sugar: Int,
        fat: Int
    ) {
        self.operationTimestamp = operationTimestamp
        calcedLevel = calculateKcalLevelSafely(operationTimestamp: operationTimestamp) ?? KcalLevel.senior
        self.protein = protein
        self.carbs = carbs
        self.sugar = sugar
        self.fat = fat
    }
  
    var body: some View {
        VStack(alignment: .center, spacing: 20) { 
            
            HeadLineText("Aktueller gebrauch: \(calcedLevel.kcal) (Kcal)")
            
            VStack(spacing: 20) {
                HStack {
                    Item(title: "Protein", current: protein, max: calcedLevel.protein)
                    Item(title: "Kohlenhydrate", current: carbs, max: calcedLevel.carbs)
                }

                HStack {
                    Item(title: "Zucker", current: sugar, max: calcedLevel.sugar)
                    Item(title: "Fett", current: fat, max: calcedLevel.fat)
                }
            }
        }
        .padding(10)
        .sectionShadow()
        .padding(.horizontal, theme.layout.padding)
    }
    
    @ViewBuilder func Item(
        title:String,
        current: Int,
        max: Int
    ) -> some View {
        VStack(spacing: 7) { 
            FootLineText(title)
            LabeledGauge(current: Double(current), minValue: 0, maxValue: Double(max))
            FootLineText("\(current)g/\(max)g")
        }
        .frame(maxWidth: .infinity)
    }
}

func calculateKcalLevelSafely(operationTimestamp: Int64) -> KcalLevel? {
    let currentTimestamp: Int64 = Date().timeIntervalSince1970Milliseconds
    let timeDifference = currentTimestamp - operationTimestamp
    
    let threeMonthsInMilliseconds: Int64 = 3 * 30 * 24 * 60 * 60 * 1000 // 3 Monate
    let sixMonthsInMilliseconds: Int64 = 6 * 30 * 24 * 60 * 60 * 1000 // 6 Monate
    
    if timeDifference <= threeMonthsInMilliseconds {
        return .junior
    } else if timeDifference <= sixMonthsInMilliseconds {
        return .mid
    } else {
        return .senior
    }
}
