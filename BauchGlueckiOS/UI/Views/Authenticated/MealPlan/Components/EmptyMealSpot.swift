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
    let firebase: FirebaseService
    let date: Date
    
    var body: some View {
        HStack {
            Text("\(index + 1).")
            
            Text("Keine Mahlzeit zugewiesen")
            
            Spacer()
            
            Image(systemName: "plus")
                .padding(.horizontal, theme.layout.padding + 5)
                .padding(.vertical, theme.layout.padding)
                .background(theme.color.backgroundGradient)
                .foregroundStyle(theme.color.onPrimary)
                .cornerRadius(100)
        }
        .font(.footnote)
        .foregroundStyle(theme.color.onBackground)
        .padding(theme.layout.padding)
        .sectionShadow()
        .padding(.horizontal, theme.layout.padding)
        .navigateTo(
            firebase: firebase,
            destination: Destination.mealPlan,
            target: { SearchRecipeScreen(firebase: firebase, date: date) },
            toolbarItems: { }
        )
    }
}
 
#Preview {
    EmptyMealSpot(index: 1, firebase: FirebaseService(), date: Date())
}
