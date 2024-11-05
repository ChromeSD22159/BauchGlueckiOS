//
//  DtaileRecipe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 04.11.24.
//

import SwiftUI
import SwiftData
 
struct DetailRecipeView: View {
    
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
    
    private var toolbarColor: Color {
        let minScrollOffset: CGFloat = 75
        let maxScrollOffset: CGFloat = 170
        
        // Begrenze den ScrollOffset-Wert zwischen den maximalen und minimalen Werten
        let clampedOffset = min(max(scrollOffset.y, minScrollOffset), maxScrollOffset)

        // Interpolation, um den progressiven Wert zwischen 0 und 1 zu berechnen
        let normalizedValue = (clampedOffset - minScrollOffset) / (maxScrollOffset - minScrollOffset)

        return Color(red: normalizedValue, green: normalizedValue, blue: normalizedValue)
    }
 
    private var toolbarBGOpacity: CGFloat {
        let minScrollOffset: CGFloat = 75
        let maxScrollOffset: CGFloat = 170

        // Begrenze den ScrollOffset-Wert zwischen den maximalen und minimalen Werten
        let clampedOffset = min(max(scrollOffset.y, minScrollOffset), maxScrollOffset)

        // Interpolation, um den progressiven Wert zwischen 0 und 1 zu berechnen
        let normalizedValue = (clampedOffset - minScrollOffset) / (maxScrollOffset - minScrollOffset)

        appearance.backgroundColor = theme.background.opacity(normalizedValue).toUIColor
        return normalizedValue
    }
    
    @State var appearance: UINavigationBarAppearance
    
    var theme: Theme
    var recipe: Recipe
    var firebase: FirebaseService
    
    init(firebase: FirebaseService, recipe: Recipe) {
        self.theme = Theme.shared
        self.recipe = recipe
        self.firebase = firebase
        self.appearance = UINavigationBarAppearance()
        self.appearance.configureWithOpaqueBackground()
        self.appearance.backgroundColor = self.theme.background.opacity(0.0).toUIColor
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            theme.background.ignoresSafeArea()
           
            ImageBG()

            ScrollView {
                ScrollViewOffsetTracker()
                
                ZStack {
                    
                    VStack(spacing: 25) {
                        Text(recipe.name)
                            .font(theme.headlineTextSmall)
                            .foregroundStyle(theme.onBackground)
                        
                        IconRow(
                            kcal: 22.0,
                            fat: 5.0,
                            protein: 22.0
                        )
                        
                        PreperationTimeCategoryRow(
                            preparationTimeInMinutes: 25,
                            recipeName: "String"
                        )
                        
                        TextWithTitlte(title: "Beschreibung:", text: recipe.recipeDescription)
                        
                        
                        ForEach(recipe.ingredients) { ingredient in
                            IngredientItem(ingredient: ingredient)
                        }
                         
                        TextWithTitlte(title: "Zubereitung:", text: recipe.preparation)
                        
                        Spacer()
                        
                        
                    }
                    .padding()
                    .background(theme.background.ignoresSafeArea())
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
            ToolbarItem(placement: .navigationBarLeading) {
                if let category = recipe.category {
                    HStack(spacing: 16) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text(Destination.recipeCategories.screen.title)
                            .font(.callout)
                    }
                    .navigateTo(
                        firebase: firebase,
                        destination: Destination.recipeCategories,
                        target: { SearchRecipesScreen(firebase: firebase, category: category) }
                    )
                    .shadow(radius: 2)
                    .foregroundStyle(toolbarColor)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Image(systemName: "plus")
                        .font(.body)
                }
                .foregroundStyle(toolbarColor)
                .onTapGesture {
                }
            }
        }
        .background(
            Color.blue
                .opacity(scrollOffset.y < -50 ? 1.0 : 0.0)
                .animation(.easeInOut, value: scrollOffset)
        )
        
        
    }
    
    @ViewBuilder func IngredientItem(
        ingredient: Ingredient
    ) -> some View {
        HStack {
            Text("\(ingredient.amount) \(ingredient.unit)")
            Spacer()
            Text("\(ingredient.name)")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(theme.surface)
        .sectionShadow()
    }
    
    @ViewBuilder func ImageBG() -> some View {
        GeometryReader { geometry in
            Image(.beilage)
                .resizable()
                .renderingMode(.original)
                .opacity(imageOpacity)
                .aspectRatio(contentMode: .fill)
                .scaleEffect(imageScale)
                .frame(width: geometry.size.width, height: 300)
                .clipped()
        }
        .frame(height: 300)
        .ignoresSafeArea()
    }
    
    @ViewBuilder func IconRow(
        kcal: Double,
        fat: Double,
        protein: Double
    ) -> some View {
        HStack {
            Spacer()
            
            NutrinIcon(uiImage: .fatDrop, nutrin: kcal)
            
            Spacer()
            
            NutrinIcon(uiImage: .fatDrop, nutrin: fat)
            
            Spacer()
            
            NutrinIcon(systemName: "fish", nutrin: protein)
            
            Spacer()
            
        }
    }
    
    @ViewBuilder func NutrinIcon(
        uiImage: UIImage? = nil,
        systemName: String? = nil,
        nutrin: Double
    ) -> some View {
        VStack(spacing: 10) {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .font(.title3)
                    .foregroundStyle(theme.primary)
            }
            
            if let systemName = systemName {
                Image(systemName: systemName)
                    .font(.title3)
                    .foregroundStyle(theme.primary)
            }
            
            Text(String(format: "%.0fg", nutrin))
                .foregroundStyle(theme.onBackground)
                .font(.footnote)
        }
    }
    
    @ViewBuilder func PreperationTimeCategoryRow(
        preparationTimeInMinutes: Int,
        recipeName: String
    ) -> some View {
        HStack {
            HStack {
                Image(systemName: "clock")
                    .renderingMode(.template)
                
                Text("\(preparationTimeInMinutes) Minuten")
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .renderingMode(.template)
                
                Text(recipeName)
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal, theme.padding)
        .foregroundStyle(theme.primary)
        .font(.footnote)
    }
    
    @ViewBuilder func TextWithTitlte(
        title: String,
        text: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(theme.headlineTextSmall)
            
            Text(text)
        }
    }
}

let mockRecipe = Recipe(
    id: 4,
    mealId: "c6187c8f-7b1b-4b61-b266-661cc325d4a8",
    userId: "ipEn4nWseaU3IHrMV9Wy4Nio4wF2",
    name: "Frittata mit Spinat und Schinken",
    recipeDescription: "Mit diesem Rezept zauberst du im Handumdrehen kleine, herzhafte Spinat-Quiches, die sowohl kalt als auch warm schmecken. Die Kombination aus Blätterteig, Spinat, Schinken und der cremigen Füllung macht diese Quiches zu einem echten Genuss. Perfekt für alle, die schnelle und leckere Rezepte lieben.",
    preparation: "1. Ein Muffinblech, mit 12 Mulden, mit etwas Margarine bestreichen. Den Backofen vorheizen.\n2. 4 Filoteigblätter in 9 Quadrate schneiden und in jede Mulde 3 Quadrate legen.\n3. Den Spinat fein hacken und auf die Mulden verteilen.\n4. Den Schinken würfeln und auf den Spinat geben.\n5. Die Eier, Ziegenjoghurt und Gewürze mit dem Schneebesen zu einer Eiermilch verrühren und gleichmäßig verteilen.\n6. Lauchzwiebel in feine Ringe schneiden und auf die Eiermilch geben.\n7. Backzeit: 30 Minuten, mittlere Schiene, Ober/Unterhitze bei 180 Grad",
    preparationTimeInMinutes: 20,
    protein: 8,
    fat: 4,
    sugar: 5,
    kcal: 88,
    isSnack: false,
    isPrivate: false,
    isDeleted: false,
    updatedAtOnDevice: "1728634606862",
    ingredients: [
        Ingredient(id: 1, component: "", name: "Filoteig", amount: "4", unit: "Blätter"),
        Ingredient(id: 2, component: "", name: "Spinat", amount: "240", unit: "g"),
        Ingredient(id: 3, component: "", name: "Lauchzwiebeln", amount: "3", unit: "Stk"),
        Ingredient(id: 4, component: "", name: "Schinken", amount: "90", unit: "g"),
        Ingredient(id: 5, component: "", name: "Eier", amount: "5", unit: "Stk"),
        Ingredient(id: 6, component: "", name: "griechischer Joghurt", amount: "200", unit: "g")
    ],
    category: Category(id: 4, categoryId: "hauptgericht", name: "Hauptgericht")
)

#Preview {
    NavigationStack {
    
        List {
            NavigationLink(destination: {
                DetailRecipeView(firebase: FirebaseService(), recipe: mockRecipe)
                   
            }, label: {
                Text("Link")
            })
            
            NavigationLink(destination:  DetailRecipeView(firebase: FirebaseService(), recipe: mockRecipe), label: {
                Text("Link")
            })
        }
        .listStyle(.plain)
        .navigationTitle("<Category> Rezepte")
        
    }
}
