//
//  DtaileRecipe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 04.11.24.
//

import SwiftUI
import SwiftData
 
struct DetailRecipeView: View {
    var theme: Theme
    
    @EnvironmentObject var services: Services
    
    @State var scrollOffset: CGPoint = .zero
    
    private var imageOpacity: CGFloat {
        let minScrollOffset: CGFloat = 75
        let maxScrollOffset: CGFloat = 170

        // Begrenze den ScrollOffset-Wert zwischen den maximalen und minimalen Werten
        let clampedOffset = min(max(scrollOffset.y, minScrollOffset), maxScrollOffset)

        // Interpolation, um den Opacity-Wert zu berechnen
        return (clampedOffset - minScrollOffset) / (maxScrollOffset - minScrollOffset)
    }
    
    private var imageScale: CGFloat {
        let minScrollOffset: CGFloat = 75
        let maxScrollOffset: CGFloat = 170

        // Begrenze den ScrollOffset-Wert zwischen den maximalen und minimalen Werten
        let clampedOffset = min(max(scrollOffset.y, minScrollOffset), maxScrollOffset)

        // Invertierte Interpolation, um den Skalierungswert zwischen 1.0 und 0.5 zu berechnen
        let scaleRange = 1.2 - 1.0 // Die Differenz zwischen den beiden Skalen (0.5)
        let normalizedValue = (clampedOffset - minScrollOffset) / (maxScrollOffset - minScrollOffset)

        // Verwende den invertierten Wert, um von 1.0 zu 0.5 zu skalieren
        return 1.0 + (1.2 - normalizedValue) * scaleRange
    }

    private var toolbarBGOpacity: CGFloat {
        let minScrollOffset: CGFloat = 75
        let maxScrollOffset: CGFloat = 170

        // Begrenze den ScrollOffset-Wert zwischen den maximalen und minimalen Werten
        let clampedOffset = min(max(scrollOffset.y, minScrollOffset), maxScrollOffset)

        // Interpolation, um den progressiven Wert zwischen 0 und 1 zu berechnen
        let normalizedValue = (clampedOffset - minScrollOffset) / (maxScrollOffset - minScrollOffset)

        appearance.backgroundColor = theme.color.background.opacity(normalizedValue).toUIColor
        return normalizedValue
    }
    
    @State var appearance: UINavigationBarAppearance
    
    @State var isDateSheet = false
    @State private var navigateToMealPlan = false
    
    var recipe: Recipe
    var date: Date?
    
    init(recipe: Recipe, date: Date? = nil, theme: Theme) {
        self.theme = theme
        self.recipe = recipe
        self.date = date
        self.appearance = UINavigationBarAppearance()
        self.appearance.configureWithOpaqueBackground()
        self.appearance.backgroundColor = theme.color.background.opacity(0.0).toUIColor
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            theme.color.background.ignoresSafeArea()
           
            if let image = recipe.mainImage {
                ImageBG(image: image)
            }

            ScrollView {
                ScrollViewOffsetTracker()
                
                ZStack {
                    
                    VStack(spacing: 25) {
                        Text(recipe.name)
                            .font(theme.font.headlineTextSmall)
                            .foregroundStyle(theme.color.onBackground)
                        
                        IconRow(
                            kcal: recipe.kcal,
                            fat: recipe.fat,
                            protein: recipe.protein,
                            sugar: recipe.sugar
                        )
                        
                        PreperationTimeCategoryRow(
                            preparationTimeInMinutes: recipe.preparationTimeInMinutes,
                            recipeName: recipe.category?.name ?? "Nicht kategorisiert"
                        )
                        
                        TextWithTitlte(title: "Beschreibung:", text: recipe.recipeDescription)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Zutaten:")
                                .font(theme.font.headlineTextSmall)
                            
                            ForEach(recipe.ingredients) { ingredient in
                                DetailRecipeIngredientItem(ingredient: ingredient)
                            }
                        }
                        
                         
                        TextWithTitlte(title: "Zubereitung:", text: recipe.preparation)
                        
                        Spacer()
                         
                    }
                    .padding()
                    .background(theme.color.background.ignoresSafeArea())
                    .clipShape(RoundedCornersShape(radius: 15, corners: [.topLeft, .topRight]))
                    .shadow(radius: 10, y: -5)
                }
            }
            .withOffsetTracking(action: {
                scrollOffset = $0
            })
            .contentMargins(.top, 170)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.body)
                }
                .onTapGesture {
                    if let date = date {
                        services.mealPlanService.addToMealPlan(meal: recipe, date: date)
                        navigateToMealPlan = true
                    } else {
                        isDateSheet.toggle()
                    }
                }
            }
        }
        .background(
            Color.blue
                .opacity(scrollOffset.y < -50 ? 1.0 : 0.0)
                .animation(.easeInOut, value: scrollOffset)
        )
        .datePickerSheet(date: date, isSheet: $isDateSheet) { date in
            services.mealPlanService.addToMealPlan(meal: recipe, date: date)
            
            navigateToMealPlan = true
        }
        .navigateTo(
            destination: Destination.detailRecipes,
            isActive: $navigateToMealPlan,
            showSettingButton: false, 
            target: {
                MealPlanScreen(currentDate: date, services: services)
            }
        )
    }
    
    @ViewBuilder func ImageBG(
        image: MainImage
    ) -> some View {
        GeometryReader { geometry in
            
            AsyncCachedImage(url: URL(string: services.apiService.baseURL + image.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(imageScale)
                    .recipeImage(width: geometry.size.width, height: 300, opacity: imageOpacity)
            } placeholder: {
                ZStack{
                    Image(uiImage: .placeholder)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(imageScale)
                        .recipeImage(width: geometry.size.width, height: 300, opacity: imageOpacity)
                }
            }
            
        }
        .frame(height: 300)
        .ignoresSafeArea()
    }
    
    
}
 
 
#Preview {
    GeometryReader { geometry in
        Image(.beilage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .recipeImage(width: geometry.size.width, height: 300, opacity: 1.0)
            
    }
}
 

