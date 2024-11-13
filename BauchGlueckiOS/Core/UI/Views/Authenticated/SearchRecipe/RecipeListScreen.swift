//
//  SearchRecipesScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI
import SwiftData
import Combine

struct RecipeListScreen: View {
    let theme = Theme.shared
    
    var firebase: FirebaseService
    
    @Query() var recipes: [Recipe]
    
    init(firebase: FirebaseService, categoryId: String) {
        self.firebase = firebase
        
        let predicate = #Predicate<Recipe> { recipe in
            if let recipeCategory = recipe.category {
                return recipeCategory.categoryId == categoryId
            }  else { return false }
        }

        _recipes = Query(filter: predicate)
    }
    
    let columns = [
       GridItem(.flexible()),
       GridItem(.flexible())
   ]
    
    var body: some View {
        ScreenHolder {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(recipes, id: \.self) { recipe in
                        
                        RecipePreviewCard(mainImage: recipe.mainImage, name: recipe.name, fat: recipe.fat, protein: recipe.protein)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.recipeCategoryList,
                                showSettingButton: false,
                                target: { DetailRecipeView(firebase: firebase, recipe: recipe) }
                            )
                        
                    }
                }
                .padding(theme.padding)
            }
        }
    }
}
