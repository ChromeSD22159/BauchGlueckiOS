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
    
    @Query() var recipeCategorys: [Category]
    
    var body: some View {
        ScreenHolder {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(recipeCategorys) { category in
                        if let categoryImage = RecipeCategory.from(category.categoryId) {
                            RecipeImageCard(image: categoryImage.image, name: category.name)
                                .navigateTo(
                                    firebase: firebase,
                                    destination: Destination.searchRecipes,
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

struct RecipeImageCard: View {
    var image: ImageResource
    var name: String
    private let theme: Theme = Theme.shared
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack(alignment: .center) {
                Text(name)
                    .font(theme.headlineTextSmall)
                    .foregroundStyle(theme.onBackground)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(theme.surface.opacity(0.9))
        }
        .sectionShadow()
    }
}
