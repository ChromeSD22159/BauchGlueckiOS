//
//  RecipeGrid.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.11.24.
//
import SwiftUI

struct RecipeGrid: View {
    @Environment(\.theme) private var theme
    
    private let spacing: CGFloat = 16
    
    var recipes: [Recipe]
    var date: Date? = nil
    var resultCount: Bool
    
    let colums: Int = 2
    
    var body : some View {
        VStack {
            LazyVGrid(columns: GridUtils.createGridItems(count: 2, spacing: spacing), spacing: spacing) {
                ForEach(recipes, id: \.self) { recipe in
                    RecipePreviewCard(
                        mainImage: recipe.mainImage,
                        name: recipe.name,
                        fat: recipe.fat,
                        protein: recipe.protein,
                        width: calcItemWidth(width: ScreenSizeUtil.width)
                    )
                    .navigateTo(
                        destination: Destination.recipeCategoryList,
                        showSettingButton: false,
                        target: { DetailRecipeView(recipe: recipe, date: date, theme: theme) }
                    )
                }
            } 
              
            if resultCount { 
                FootLineText("\(recipes.count) Rezepte gefunden!")
                    .padding(.top, 20)
                    .padding(.horizontal, theme.layout.padding)
            }
        }
    }
    
    func calcItemWidth(width: CGFloat) -> CGFloat {
        return (width - (spacing * 3)) / 2
    }
    
    func calcNumOfRows(columns: Int = 2) -> CGFloat {
        let numOfRows: Int = Int(ceil(Double(recipes.count) / Double(columns)))
        
        return CGFloat(numOfRows)
    }
}
