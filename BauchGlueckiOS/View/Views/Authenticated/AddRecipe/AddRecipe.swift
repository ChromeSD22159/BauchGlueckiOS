//
//  AddRecipe.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//

import SwiftUI
import SwiftData
import FirebaseAuth
 
struct AddRecipe: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject var service: Services
    @FocusState private var focusedField: FocusedField?
    @Binding var isPresented: Bool
    var navTitle: String
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

    // OVERLAY
    @State var animateOverlay = false
    @State var phase: UploadRecipePhase = .notStarted
    @State var timer: Timer? = nil
    @State var errorText = ""
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ImageChoose()
                            
                            Form()
                            
                            Controll()
                        }
                        .padding(.horizontal, theme.layout.padding)
                    }
                    .opacity(animateOverlay ? 0.5 : 1.0)
                    .animation(.easeInOut, value: animateOverlay)
                    .contentMargins(.top, 20)
                    .sheet(isPresented: $isImagePicker) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: $recipeImage)
                    }
                    
                    if animateOverlay {
                        VStack(alignment: .center, spacing: 10) {
                            Spacer()
                            HStack {
                                Spacer()
                                SaveOverlay(geo: geo, errorText: errorText, animate: $animateOverlay, phase: $phase)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .navigationTitle(navTitle)
                .navigationBarTitleDisplayMode(.inline)
                .onTapGesture { focusedField = closeKeyboard(focusedField: focusedField) }
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
        .padding(theme.layout.padding)
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
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Kurze Beschreibung des Rezepts",
                icon: "text.bubble",
                title: "Beschreibung:",
                input: $recipeDescription,
                type: .editText,
                focusedField: $focusedField,
                fieldType: .name,
                onEditingChanged: { newValue in
                    recipeDescription = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Zubereitungsschritte eingeben",
                icon: "list.bullet.rectangle",
                title: "Zubereitung:",
                input: $recipePreperation,
                type: .editText,
                focusedField: $focusedField, 
                fieldType: .preperation,
                onEditingChanged: { newValue in
                    recipePreperation = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
            
            TextFieldWithIcon<FocusedField>(
                placeholder: "Zubereitungszeit in Minuten (z.B. 20)",
                icon: "clock",
                title: "Zubereitungszeit:",
                input: $recipePreperationTime,
                type: .text,
                focusedField: $focusedField,
                fieldType: .preperationTime,
                keyboardType: .numberPad,
                onEditingChanged: { newValue in
                    recipePreperationTime = newValue
                }
            )
            .sectionShadow(innerPadding: 10)
           
            VStack {
                if ingredients.count == 0 {
                    VStack {
                        Text("Keine Zutaten vohanden")
                    }.sectionShadow(innerPadding: 10)
                } else {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            
                            TextField("Zutat", text: $ingredient.name)
                                .frame(maxWidth: .infinity) // Allow remaining space for other fields
                                .lineLimit(1) // Ensure name stays on one line (optional)
                                .truncationMode(.tail) // Truncate name if too long (optional)
                            
                            Spacer(minLength: 0) // Force even spacing between fields

                            // Menge TextField with max width (50) and number pad keyboard
                            TextField("Menge", text: $ingredient.amount)
                                .frame(maxWidth: 100)
                                .keyboardType(.numberPad)

                            Spacer(minLength: 0) // Force even spacing between fields
                            
                            Picker("Einheit", selection: Binding(
                                get: { IngredientUnit.fromUnit(ingredient.unit) },
                                set: { ingredient.unit = $0.unit }
                            )) {
                                ForEach(IngredientUnit.allCases, id: \.self) { unit in
                                    Text(unit.name).tag(unit)
                                }
                            }
                            .frame(maxWidth: 100)
                            .accentColor(theme.color.onBackground)
                            .tint(theme.color.onBackground)
                            .pickerStyle(.menu) // Use menu style for accessibility
                            .foregroundColor(theme.color.onBackground) // Use label color
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
                    ForEach(RecipeCategory.allEntriesSortedByName, id: \.self) { category in
                        Text(category.displayName)
                            .tag(category)
                    }
                }
                .accentColor(theme.color.onBackground)
                .tint(theme.color.onBackground)
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

    @ViewBuilder func Controll() -> some View {
        HStack {
            FullSizeButton(title: "Abbrechen"){
                closeOverlay()
            }
            
            FullSizeButton(title: "Speichern") {
                animateOverlay = true
                
                guard let preparationTime = Int(recipePreperationTime) else { return showError(text: "Die Zeit darf nur als Zahl angegeben werden.") }
                
                guard recipeImage.size != .zero else { return showError(text: "Kein Bild ausgewählt") }
                
                guard recipeDescription.count >= 10 else { return showError(text: "Beschreibung ist zu kurz") }
  
                guard !recipeName.isEmpty else { return showError(text: "Der Name des Rezepts darf nicht leer sein.") }

                guard ingredients.count > 0 else { return showError(text: "Mindestens eine Zutat muss angegeben werden.") }
                
                let filteredIngredients = ingredients.filter { ingredient in
                    !ingredient.name.isEmpty && !ingredient.amount.isEmpty
                }
               
                Task {
                    service.recipesService.uploadRequest(
                        recipeImage: recipeImage,
                        recipeDescription: recipeDescription,
                        recipeName: recipeName,
                        recipePreperation: recipePreperation,
                        recipePreperationTime: preparationTime,
                        ingredients: filteredIngredients,
                        selectedCategory: selectedCategory,
                        successFullUploadet: { result in
                            if case .failure(let error) = result {
                                //throw error.asAFError(orFailWith: "Fehler beim Uploaden")
                                showError(text: "Speichern fehlgeschlagen: \(error.localizedDescription)")
                            } else {
                                service.fetchFrombackend()
                                closeOverlay()
                            }
                        }
                    )
                }
            }
        }
    }
    
    func showError(text: String) {
        errorText = text
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            errorText = ""
        }
       
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
            animateOverlay = false
        }
    }
    
    func closeOverlay() {
        animateOverlay = false
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            isPresented = false
        }
    }
    
    private func closeKeyboard(focusedField: FocusedField?) -> FocusedField? {
        if focusedField != nil {
            return nil
        }
        
        return focusedField
    }
    
    enum FocusedField {
        case name, description, preperation, preperationTime
    }
}

struct SaveOverlay: View {
    @Environment(\.theme) private var theme
    
    let geo: GeometryProxy
    let errorText: String
    @Binding var animate: Bool
    @Binding var phase: UploadRecipePhase
    @State private var timer: Timer?
    @State private var rotationAngle: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if errorText.isEmpty {
                Text("Dein Rezept wird gespeichert...")
            } else {
                Text("Dein Rezept konnte nicht gespeichert werden!")
            }
            
            Spacer()
            if errorText.isEmpty {
                step(icon: phaseIcon(for: .uploadImage), text: "Bild Upload", isCompleted: phase.rawValue >= UploadRecipePhase.uploadImage.rawValue)
                step(icon: phaseIcon(for: .nutrinGeneration), text: "Nährwerte generieren", isCompleted: phase.rawValue >= UploadRecipePhase.nutrinGeneration.rawValue)
                step(icon: phaseIcon(for: .SaveRecipe), text: "Rezept speichern", isCompleted: phase.rawValue >= UploadRecipePhase.SaveRecipe.rawValue)
            } else {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(.horizontal, theme.layout.padding * 2)
        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
        .background(Material.ultraThinMaterial)
        .cornerRadius(geo.size.width * 0.8 / 10)
        .shadow(radius: 20)
        .onAppear {
            if animate && errorText.isEmpty {
                startTimer()
            }
            if animate && !errorText.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    timer?.invalidate()
                    phase = .notStarted
                    animate.toggle()
                })
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if phase == .done {
                timer?.invalidate()
                phase = .notStarted
                animate.toggle()
            } else {
                phase = UploadRecipePhase(rawValue: phase.rawValue + 1) ?? .done
            }
        }
    }
 
    func phaseIcon(for targetPhase: UploadRecipePhase) -> String {
        switch phase {
            case targetPhase: return "ProgressView"
            case _ where phase.rawValue > targetPhase.rawValue: return "checkmark.seal"
            default: return "circle"
        }
    }

    @ViewBuilder func step(icon: String, text: String, isCompleted: Bool) -> some View {
        HStack {
            ZStack {
                if  icon == "ProgressView" {
                        ProgressView()
                } else {
                    Image(systemName: icon)
                        .foregroundColor(isCompleted ? .primary : .gray)
                }
            }.frame(width: 15, height: 15)
            
            Spacer()
            
            Text(text)
                .foregroundColor(isCompleted ? .primary : .gray)
        }
        .font(.footnote)
        .transition(.scale)
        .animation(.easeInOut(duration: 0.5), value: isCompleted)
    }
}

enum UploadRecipePhase: Int {
    case notStarted, uploadImage, nutrinGeneration, SaveRecipe, done
}
