//
//  RecipeCategoryScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//

import SwiftUI
import SwiftData

struct RecipeCategoryScreen: View {
    let theme = Theme.shared
    
    var firebase: FirebaseService
    
    @Query(sort: \Category.name) var recipeCategorys: [Category]
    
    var recipeCategorysSortedByName: [RecipeCategory] {
        return recipeCategorys
            .compactMap { RecipeCategory.fromCategoryID($0.categoryId) }
            .sorted { $0.displayName < $1.displayName }
    }
    
    var body: some View {
        ScreenHolder {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(recipeCategorysSortedByName, id: \.rawValue) { category in
                        RecipeImageCard(image: category.image, name: category.displayName)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.recipeCategories,
                                target: { SearchRecipesScreen(firebase: firebase, categoryId: category.categoryID) },
                                toolbarItems: {
                                    AddRecipeButtonWithPicker()
                                }
                            )
                    }
                }
                .padding(theme.padding)
            }
        }
    }
}

#Preview {
    let theme: Theme = Theme.shared
    let recipeCategories: [RecipeCategory] = [.beilage, .dessert, .hauptgericht, .lowCarb]
    ZStack {
        theme.background
        
        ScrollView {
            ForEach(recipeCategories, id: \.self) { category in
                RecipeImageCard(image: category.image, name: "CategoryName")
            }
        }
        .contentMargins(.top, 10)
    }
}  
