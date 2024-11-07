//
//  AddRecipe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

import SwiftUI
import SwiftData
import FirebaseAuth

#Preview {
    AddRecipeButtonWithPicker()
}

struct AddRecipeButtonWithPicker: View {
    @State var isRecipeSheet = false
    var body: some View {
        Button(action: {
            isRecipeSheet.toggle()
        }, label: {
           Image(systemName: "plus")
                .foregroundStyle(Theme.shared.onBackground)
        })
        .sheet(isPresented: $isRecipeSheet, onDismiss: {}, content: {
            AddRecipe(
                dissmiss: { isRecipeSheet.toggle() },
                onSave: { recipe in
                }
            )
            .presentationDragIndicator(.visible)
        })
    }
}

struct AddRecipe: View {
    @EnvironmentObject var service: Services
    @FocusState private var focusedField: FocusedField?

    // Recipe
    @State var recipeName: String = ""
    @State var recipeDescription: String = ""
    @State var recipePreperation: String = ""
    @State var recipePreperationTime: String = ""
    @State var selectedCategory: RecipeCategory = .hauptgericht
    @State var ingredients: [Ingredient] = []
    @State var isPrivate = false
    
    // ImagePicker
    @State var isImagePicker = false
    @State var recipeImage: UIImage = UIImage()
    
    @State var overlay: Bool = false
    @State var errorText = ""
    
    var dissmiss: () -> Void
    var onSave: (Recipe) -> Void
    
    init(
        dissmiss: @escaping () -> Void,
        onSave: @escaping (Recipe) -> Void
    ) {
        self.dissmiss = dissmiss
        self.onSave = onSave
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ImageChoose()
                        
                        Form()
                        
                        Controll()
                    }
                    .padding(.horizontal, Theme.shared.padding)
                }
                .opacity(overlay ? 0.5 : 1.0)
                .animation(.easeInOut, value: overlay)
                .contentMargins(.top, 20)
                .sheet(isPresented: $isImagePicker) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $recipeImage)
                }
                
                if overlay {
                    SaveOverlay(geo: geo)
                }
            }
        }
    }
    
    @ViewBuilder func ImageChoose() -> some View {
        VStack {
            if (recipeImage.cgImage != nil) {
             
                Image(uiImage: recipeImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedCornersShape(radius: 10))
            } else {
                Image(.placeholder)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedCornersShape(radius: 10))
            }
            
            HStack {
                FullSizeButton(title: "Bild auswählen"){
                    isImagePicker.toggle()
                }
                
                if (recipeImage.cgImage != nil) {
                    FullSizeButton(title: "Bild entfernen"){
                        recipeImage = UIImage()
                    }
                }
                
            }
        }
        .padding(Theme.shared.padding)
        .clipShape(RoundedCornersShape(radius: 10))
        .sectionShadow()
    }
    
    @ViewBuilder func Form() -> some View {
        VStack(spacing: 10) {
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Rezeptname eingeben",
                icon: "book",
                title: "Rezeptname:",
                input: $recipeName,
                type: .text,
                focusedField: $focusedField,
                fieldType: .name,
                onEditingChanged: { newValue in
                    recipeName = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
            .submitLabel(.next)
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Kurze Beschreibung des Rezepts",
                icon: "text.bubble",
                title: "Beschreibung:",
                input: $recipeDescription,
                type: .text,
                focusedField: $focusedField,
                fieldType: .name,
                onEditingChanged: { newValue in
                    recipeDescription = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
            .submitLabel(.next)
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Zubereitungsschritte eingeben",
                icon: "list.bullet.rectangle",
                title: "Zubereitung:",
                input: $recipePreperation,
                type: .text,
                focusedField: $focusedField,
                fieldType: .preperation,
                onEditingChanged: { newValue in
                    recipePreperation = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
            .submitLabel(.next)
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Zubereitungszeit in Minuten (z.B. 20)",
                icon: "clock",
                title: "Zubereitungszeit:",
                input: $recipePreperationTime,
                type: .text,
                focusedField: $focusedField,
                fieldType: .preperationTime,
                onEditingChanged: { newValue in
                    recipePreperationTime = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
            .submitLabel(.done)
           
            VStack {
                if ingredients.count == 0 {
                    VStack {
                        Text("Keine Zutaten vohanden")
                    }.sectionShadow(innerPadding: 10)
                } else {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            
                            TextField("Zutat", text: $ingredient.name)
                                   
                            TextField("Menge", text: $ingredient.amount)
                           
                            Picker("Einheit", selection: Binding(
                                get: { IngredientUnit.fromUnit(ingredient.unit) },
                                set: { ingredient.unit = $0.unit }
                            )) {
                                ForEach(IngredientUnit.allCases, id: \.self) { unit in
                                    Text(unit.name).tag(unit)
                                }
                            }
                            .accentColor(Theme.shared.onBackground)
                            .tint(Theme.shared.onBackground)
                        }.sectionShadow(innerPadding: 10)
                    }
                }
                
                FullSizeImageButton(icon: "plus", title: "Hinzufügen", onClick: {
                    ingredients.append(
                        Ingredient(
                            id: ingredients.count + 1,
                            component: "",
                            name: "",
                            amount: "",
                            unit: IngredientUnit.gramm.unit
                        )
                    )
                })
            }
            .sectionShadow(innerPadding: 10)
            
            HStack {
                Text("Rezept Kategorie")
                Spacer()
                Picker("Rezept Kategorie", selection: $selectedCategory) {
                    ForEach(RecipeCategory.allCases, id: \.self) { category in
                        Text(category.displayName)
                            .tag(category)
                    }
                }
                .accentColor(Theme.shared.onBackground)
                .tint(Theme.shared.onBackground)
            }
            .sectionShadow(innerPadding: 10)
            
            Toggle(isOn: $isPrivate, label: {
                Text("Privates Rezept")
            })
            .sectionShadow(innerPadding: 10)
            
        }
        .onSubmit {
            switch focusedField {
                case .name: focusedField = .description
                case .description: focusedField = .preperation
                case .preperation: focusedField = .preperationTime
                case .preperationTime: break
                default: break
            }
       }
    }
    
    @ViewBuilder func SaveOverlay(geo: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Speichern")
            
            Text(errorText)
                .font(.footnote)
                .foregroundStyle(.red)
        }
        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
        .background(Material.ultraThinMaterial)
        .cornerRadius(geo.size.width * 0.8 / 10)
        .shadow(radius: 20)
        .animation(.easeInOut, value: overlay)
    }
    
    @ViewBuilder func Controll() -> some View {
        HStack {
            FullSizeButton(title: "Abbrechen"){
                dissmiss()
            }
            
            FullSizeButton(title: "Speichern") {
                overlay = true
                
                guard let preparationTime = Int(recipePreperationTime) else { return showError(text: "Die Zeit darf nur als Zahl angegeben werden.") }
                
                guard recipeImage.size != .zero else { return showError(text: "Kein Bild ausgewählt") }
                
                guard recipeDescription.count >= 10 else { return showError(text: "Beschreibung ist zu kurz") }
  
                guard !recipeName.isEmpty else { return showError(text: "Der Name des Rezepts darf nicht leer sein.") }

                guard ingredients.count > 0 else { return showError(text: "Mindestens eine Zutat muss angegeben werden.") }
                
                for ingredient in ingredients {
                    guard !ingredient.name.isEmpty else { return showError(text: "Jede Zutat muss einen Namen haben.") }
                    guard !ingredient.amount.isEmpty else { return showError(text: "Jede Zutat muss eine Menge haben.") }
                }
                
                service.recipesService.uploadRequest(
                    recipeImage: recipeImage,
                    recipeDescription: recipeDescription,
                    recipeName: recipeName,
                    recipePreperation: recipePreperation,
                    recipePreperationTime: preparationTime,
                    ingredients: ingredients,
                    selectedCategory: selectedCategory
                ) { result in
                    switch result {
                        case .success(_):
                        
                            dissmiss()
                            closeOverlay()
                        
                        case .failure(_): print("Error")
                    }
                }
            }
        }
    }
    
    func showError(text: String) {
        errorText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            errorText = ""
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            overlay = false
        })
    }
    
    func closeOverlay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            overlay = false
        })
    }
    
    enum FocusedField {
        case name, description, preperation, preperationTime
    }
}

struct FullSizeButton: View {
    let title: String
    let onClick: () -> Void
    var body: some View {
        Button(action: {
            onClick()
        }, label: {
            Text(title)
        })
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.shared.padding)
        .padding(.vertical, Theme.shared.padding.subtractGoldenRatio)
        .foregroundStyle(Theme.shared.onPrimary)
        .background(
            Capsule()
                .fill(Theme.shared.backgroundGradient)
        )
    }
}

struct FullSizeImageButton: View {
    let icon: String
    let title: String
    let onClick: () -> Void
    var body: some View {
        Button(action: {
            onClick()
        }, label: {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
        })
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.shared.padding)
        .padding(.vertical, Theme.shared.padding.subtractGoldenRatio)
        .foregroundStyle(Theme.shared.onPrimary)
        .background(
            Capsule()
                .fill(Theme.shared.backgroundGradient)
        )
    }
} 


struct RecipeUpload: Codable {
    let updatedAtOnDevice: Int64
    let mealId: String
    let userId: String
    let description: String
    let isDeleted: Bool
    let isPrivate: Bool
    let isSnack: Bool
    let name: String
    let preparation: String
    let preparationTimeInMinutes: Int
    let ingredients: [IngredientResponse]
    let mainImage: MainImageUpload
    let category: CategoryUpload
    let protein: Double
    let fat: Double
    let sugar: Double
    let kcal: Double

    init(
        updatedAtOnDevice: Int64,
        mealId: String,
        userId: String,
        description: String,
        isDeleted: Bool = false,
        isPrivate: Bool = false,
        isSnack: Bool = false,
        name: String,
        preparation: String,
        preparationTimeInMinutes: Int,
        ingredients: [IngredientResponse],
        mainImage: MainImageUpload,
        category: CategoryUpload,
        protein: Double = 0.0,
        fat: Double = 0.0,
        sugar: Double = 0.0,
        kcal: Double = 0.0
    ) {
        self.updatedAtOnDevice = updatedAtOnDevice
        self.mealId = mealId
        self.userId = userId
        self.description = description
        self.isDeleted = isDeleted
        self.isPrivate = isPrivate
        self.isSnack = isSnack
        self.name = name
        self.preparation = preparation
        self.preparationTimeInMinutes = preparationTimeInMinutes
        self.ingredients = ingredients
        self.mainImage = mainImage
        self.category = category
        self.protein = protein
        self.fat = fat
        self.sugar = sugar
        self.kcal = kcal
    }
}

struct MainImageUpload: Codable {
    let id: Int
}

struct CategoryUpload: Codable {
    let name: String
}
