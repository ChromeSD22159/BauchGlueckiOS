//
//  MealPlanSpotCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI

struct MealPlanSpotCard: View { 
    @State var isActive: Bool = false
    @Environment(\.theme) private var theme
    var recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(recipe.name)
                    .font(theme.font.headlineTextSmall)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "eye")
                        .foregroundStyle(theme.color.onBackground)
                        .navigateTo(
                            destination: Destination.mealPlan,
                            target: { DetailRecipeView(recipe: recipe, theme: theme) }
                        )
                    
                    Image(systemName: "info.circle")
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isActive.toggle()
                            }
                        }
                }
            }
            
            HStack {
                IconText(uiImage: .fatDrop, value: recipe.fat)
                Spacer()
                IconText(systemName: "square.on.square", value: recipe.sugar)
                Spacer()
                IconText(systemName: "fish", value: recipe.protein)
                Spacer()
                IconText(systemName: "bolt", value: recipe.kcal)
            }
             
            if isActive {
                HStack {
                    HStack {
                        Image(systemName: "gauge.with.dots.needle.bottom.50percent.badge.plus")
                        Text("\(recipe.preparationTimeInMinutes)min")
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "eye")
                        Text("Rezept ansehen")
                    }
                    .navigateTo(
                        destination: Destination.mealPlan,
                        target: {
                            DetailRecipeView(recipe: recipe, theme: theme)
                        },
                        toolbarItems: {}
                    )
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "person.fill.viewfinder")
                        Text("\(recipe.isPrivate ? "Öffentliches" : "Privates") Rezept")
                    }
                }
                .foregroundStyle(theme.color.onBackground)
                .font(.footnote)
            }
        }
        .padding(theme.layout.padding)
        .sectionShadow()
        .padding(.horizontal, theme.layout.padding)
    }
    
    @ViewBuilder func IconText(
        uiImage: UIImage? = nil,
        systemName: String? = nil,
        value: Double = 0.0
    ) -> some View {
        HStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .foregroundColor(theme.color.onBackground)
            }
            if let systemName = systemName {
                Image(systemName: systemName)
            }
            Text(String(format: "%.1fg", value))
        }
        .font(.footnote)
        .foregroundStyle(theme.color.onBackground)
    }
}
