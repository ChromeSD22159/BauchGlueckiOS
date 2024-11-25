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
        GeometryReader { geometry in
            VStack {
                LazyVGrid(columns: GridUtils.createGridItems(count: 2, spacing: spacing), spacing: spacing) {
                    ForEach(recipes, id: \.self) { recipe in
                        RecipePreviewCard(
                            mainImage: recipe.mainImage,
                            name: recipe.name,
                            fat: recipe.fat,
                            protein: recipe.protein,
                            width: calcItemWidth(width: geometry.size.width)
                        )
                        .navigateTo( 
                            destination: Destination.recipeCategoryList,
                            showSettingButton: false,
                            target: { DetailRecipeView(recipe: recipe, date: date, theme: theme) }
                        )
                    }
                }
                .viewSize(name: "LazyVGrid", debugColor: .red)
                //.frame(height: (calcItemWidth(width: geometry.size.width) + spacing) * calcNumOfRows(columns: colums))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, spacing)
                  
                if resultCount {
                    Text("\(recipes.count) Rezepte gefunden!")
                        .font(.footnote)
                        .padding(.top, 20)
                        .padding(.horizontal, theme.layout.padding)
                }
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
