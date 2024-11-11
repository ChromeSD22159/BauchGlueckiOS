//
//  EmptyMealSpot.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct EmptyMealSpot: View {
    private let theme: Theme = Theme.shared
    let index: Int
    let firebase: FirebaseService
    let date: Date
    var body: some View {
        HStack {
            Text("\(index + 1).")
            
            Text("Keine Mahlzeit zugewiesen")
            
            Spacer()
            
            Image(systemName: "plus")
                .padding(.horizontal, theme.padding + 5)
                .padding(.vertical, theme.padding)
                .background(theme.backgroundGradient)
                .foregroundStyle(theme.onPrimary)
                .cornerRadius(100)
        }
        .font(.footnote)
        .foregroundStyle(theme.onBackground)
        .padding(theme.padding)
        .sectionShadow()
        .padding(.horizontal, theme.padding)
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
