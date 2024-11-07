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
    
    var body: some View {
        ScreenHolder {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(recipeCategorys) { category in
                        let _ = print(category.categoryId)
                        if let categoryImage = RecipeCategory.fromCategoryID(category.categoryId) {
                            RecipeImageCard(image: categoryImage.image, name: category.name)
                                .navigateTo(
                                    firebase: firebase,
                                    destination: Destination.recipeCategories,
                                    target: { SearchRecipesScreen(firebase: firebase, category: category) }
                                )
                        }
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
