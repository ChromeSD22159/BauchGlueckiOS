//
//  DetailRecipeIngredientItem.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct DetailRecipeIngredientItem: View {
    let ingredient: Ingredient
    var body: some View {
        HStack {
            Text("\(ingredient.amount) \(ingredient.unit)")
            Spacer()
            Text("\(ingredient.name)")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Theme.shared.surface)
        .sectionShadow()
    }
}
