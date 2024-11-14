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
 
    
    var body: some View {
        ScreenHolder {
            
            // MARK: CATECORY SLIDER
            CategorySlider()
            
            // MARK: RANDOMRECIPE
            RandomRecipe()
            
            // MARK: RANDOMRECIPES
            RandomRecipes(recipeCount: 6)
        }
    }
    
    private struct RandomRecipe: View {
        let theme = Theme.shared
        @Query() var allRecipes: [Recipe]
        @Environment(\.modelContext) var modelContext
        @EnvironmentObject var services: Services
        @EnvironmentObject var firebase: FirebaseService
        
        var randomRecipe: Recipe? {
            allRecipes.randomElement()
        }
        
        var body: some View {
            if let randomRecipe = randomRecipe {
                VStack(spacing: 10) {
                    
                    SectionHeader(title: "Zufalls Rezept")
                        .onTapGesture(count: 5) {
                            services.syncHistoryService.deleteSyncHistoryStamp(entity: .Meal)
                            services.mealPlanService.deleteAllMeals(meals: allRecipes)
                        }
                    
                    ZStack(alignment: .bottom) {
                        GeometryReader { geometry in
                            
                            if let url = randomRecipe.mainImage?.url {
                                
                                AsyncCachedImage(url: URL(string: services.apiService.baseURL + url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                } placeholder: {
                                    ZStack{
                                        Image(uiImage: .placeholder)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                    }
                                }
                                
                            } else {
                                AsyncCachedImage(url: URL(string: "https://de.m.wikipedia.org/wiki/Datei:Placeholder_view_vector.svg")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                   
                                } placeholder: {
                                    ZStack{
                                        Image(uiImage: .placeholder)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                                    }
                                }
                            }
                            
                        }
                        .frame(height: 420)
                        .ignoresSafeArea()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(randomRecipe.name)
                                    .font(theme.headlineTextSmall)
                                
                                Spacer()
                                
                                HStack {
                                    Image(systemName: "clock")
                                    Text("\(randomRecipe.preparationTimeInMinutes) min")
                                }
                            }.foregroundStyle(theme.onBackground)
                            
                            IconRow(kcal: randomRecipe.kcal, fat: randomRecipe.fat, protein: randomRecipe.protein, sugar: randomRecipe.sugar, horizontalCenter: true)
                            
                        }
                        .padding(10)
                    }
                    .sectionShadow(margin: 16)
                    .navigateTo(
                        firebase: firebase,
                        destination: Destination.recipeCategoryList,
                        showSettingButton: false,
                        target: { DetailRecipeView(firebase: firebase, recipe: randomRecipe) }
                    )
                    
                }
            }
        }
    }
    
    private struct CategorySlider: View {
        let theme = Theme.shared
        
        @EnvironmentObject var services: Services
        @EnvironmentObject var firebase: FirebaseService
        
        var body: some View {
            VStack(spacing: 10) {
                SectionHeader(title: "Kategorien")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(RecipeCategory.allCases, id: \.categoryID) { category in
                            VStack {
                                Image(category.sliderImage)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                
                                Text("\(category.displayName)")
                                    .font(theme.headlineTextSmall)
                                    .foregroundColor(theme.onBackground)
                            }
                            .frame(width: 150, height: 80)
                            .sectionShadow(innerPadding: 10)
                            .navigateTo(
                                firebase: firebase,
                                destination: Destination.recipeCategories,
                                target: { RecipeListScreen(firebase: firebase, categoryId: category.categoryID) },
                                toolbarItems: {
                                    AddRecipeButtonWithPicker()
                                }
                            )
                        }
                    }
                }
                .contentMargins(.bottom, 10)
                .contentMargins([.leading, .trailing], 16)
            }
        }
    }
    
    private struct SectionHeader: View {
        let title: String
        let trailingText: String? = nil
        var body: some View {
            HStack {
                Text(title)
                    .font(Theme.shared.headlineTextMedium)
                
                Spacer()
                
                if let trailingText = trailingText {
                    Text(trailingText)
                }
                
            }
            .padding(.horizontal, 16)
        }
    }
    
    private struct RandomRecipes: View {
        @EnvironmentObject var services: Services
        @EnvironmentObject var firebase: FirebaseService
        
        @Query() var recipes: [Recipe]
        
        let recipeCount: Int
        
        var randomRecipes: [Recipe] {
            if !recipes.isEmpty {
                return Array(recipes.shuffled().prefix(self.recipeCount))
            } else {
                return []
            }
        }
        
        private let columns = [
           GridItem(.flexible(), spacing: 16),
           GridItem(.flexible(), spacing: 16),
        ]
        
        init(recipeCount: Int = 10) {
            self.recipeCount = recipeCount
        }
        
        var body: some View {
            VStack(spacing: 10) {
                SectionHeader(title: "Zufalls Rezepte")
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(randomRecipes, id: \.self) { recipe in
                        RecipePreviewCard(
                            mainImage: recipe.mainImage,
                            name: recipe.name,
                            fat: recipe.fat,
                            protein: recipe.protein
                        )
                        .navigateTo(
                            firebase: firebase,
                            destination: Destination.recipeCategoryList,
                            showSettingButton: false,
                            target: { DetailRecipeView(firebase: firebase, recipe: recipe) }
                        )
                        
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
