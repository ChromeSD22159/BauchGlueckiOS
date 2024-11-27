//
//  EmptyMealSpot.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct EmptyMealSpot: View {
    @Environment(\.theme) private var theme
    
    let index: Int
    let date: Date
    
    var body: some View {
        HStack {
            FootLineText("\(index + 1).", color: theme.color.onBackground)
            
            FootLineText("Keine Mahlzeit zugewiesen", color: theme.color.onBackground)
            
            Spacer()
            
            Image(systemName: "plus")
                .font(.footnote)
                .padding(.horizontal, theme.layout.padding + 5)
                .padding(.vertical, theme.layout.padding)
                .background(theme.color.backgroundGradient)
                .foregroundStyle(theme.color.onPrimary)
                .cornerRadius(100)
        }
        .padding(theme.layout.padding)
        .sectionShadow()
        .padding(.horizontal, theme.layout.padding)
        .navigateTo( 
            destination: Destination.mealPlan,
            target: { SearchRecipeScreen(date: date) },
            toolbarItems: { }
        )
    }
}
 
#Preview {
    EmptyMealSpot(index: 1, date: Date())
}
