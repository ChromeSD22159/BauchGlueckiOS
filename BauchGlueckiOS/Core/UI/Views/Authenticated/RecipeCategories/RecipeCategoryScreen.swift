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
    
    @EnvironmentObject var services: Services
    
    @Query(sort: \Category.name) var recipeCategorys: [Category]
    
    @Query() var allRecipes: [Recipe]
    
    var randomRecipe: Recipe? {
        allRecipes.randomElement()
    }
    
    var recipeCategorysSortedByName: [RecipeCategory] {
        return recipeCategorys
            .compactMap { RecipeCategory.fromCategoryID($0.categoryId) }
            .sorted { $0.displayName < $1.displayName }
    }
    
    var body: some View {
        ScreenHolder {
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
            
            VStack(spacing: 10) {
                HStack {
                    Text("Rezept des Tages")
                        .font(theme.headlineTextMedium)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                ZStack(alignment: .bottom) {
                    GeometryReader { geometry in
                        
                        if let url = randomRecipe?.mainImage?.url {
                            CachedAsyncImage(url: URL(string: services.apiService.baseURL + url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                               
                            } placeholder: { }
                        } else {
                            CachedAsyncImage(url: URL(string: "https://de.m.wikipedia.org/wiki/Datei:Placeholder_view_vector.svg")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                               
                            } placeholder: { }
                        }
                        
                    }
                    .frame(height: 420)
                    .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(randomRecipe?.name ?? "")
                                .font(theme.headlineTextSmall)
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "clock")
                                Text("10 min")
                            }
                        }
                        
                        IconRow(kcal: randomRecipe?.kcal ?? 0, fat: randomRecipe?.fat ?? 0, protein: randomRecipe?.protein ?? 0, sugar: randomRecipe?.sugar ?? 0, horizontalCenter: false)
                        
                    }
                    .padding(10)
                }
                .sectionShadow(margin: 16)
                
            }
        }
    }
} 

#Preview {
    let theme: Theme = Theme.shared
    let recipeCategories: [RecipeCategory] = [.beilage, .dessert, .hauptgericht, .lowCarb]
    ZStack {
        theme.background
        
        Text("Recipe Categories")
            .font(theme.headlineTextSmall)
            .foregroundColor(theme.primary)
        ScrollView {
            
            VStack(spacing: 50) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(RecipeCategory.allCases, id: \.categoryID) { category in
                            VStack {
                                Image(category.sliderImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                
                                HStack(spacing: 5) {
                                    Text("\(category.displayName)")
                                    
                                    Text("(\(5))")
                                }
                                .font(theme.headlineTextSmall)
                                .foregroundColor(theme.primary)
                            }
                            .frame(width: 150, height: 80)
                            .sectionShadow(innerPadding: 10)
                        }
                    }
                }
                .contentMargins([.leading, .trailing, .bottom], 10)
                
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Rezept des Tages")
                            .font(theme.headlineTextMedium)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    
                    ZStack(alignment: .bottom) {
                        GeometryReader { geometry in
                            
                            CachedAsyncImage(url: URL(string: "https://images.lecker.de/kartoffel-cordon-bleu-b,id=677c3ef9,b=lecker,w=850,ca=0,11.44,100,86.17,rm=sk.webp")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .recipeImage(width: geometry.size.width, height: 300, opacity: 1)
                               
                            } placeholder: { }
                            
                        }
                        .frame(height: 420)
                        .ignoresSafeArea()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("RezeptName")
                                    .font(theme.headlineTextSmall)
                                
                                Spacer()
                                
                                HStack {
                                    Image(systemName: "clock")
                                    Text("10 min")
                                }
                            }
                            
                            IconRow(kcal: 200, fat: 10, protein: 20, sugar: 5, horizontalCenter: false)
                            
                        }
                        .padding(10)
                    }
                    .sectionShadow(margin: 10)
                    
                }
            }
            
        }
        .contentMargins(.top, 10)
    }
}  
