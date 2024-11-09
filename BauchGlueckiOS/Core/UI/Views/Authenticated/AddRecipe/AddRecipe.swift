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
    @State var animate = false
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
                        .padding(.horizontal, Theme.shared.padding)
                    }
                    .opacity(animate ? 0.5 : 1.0)
                    .animation(.easeInOut, value: animate)
                    .contentMargins(.top, 20)
                    .sheet(isPresented: $isImagePicker) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: $recipeImage)
                    }
                    
                    if animate {
                        VStack(alignment: .center, spacing: 10) {
                            Spacer()
                            HStack {
                                Spacer()
                                SaveOverlay(geo: geo, errorText: errorText, animate: $animate, phase: $phase)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .navigationTitle(navTitle)
                .navigationBarTitleDisplayMode(.inline)
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
                    ForEach(RecipeCategory.allEntriesSortedByName, id: \.self) { category in
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

    @ViewBuilder func Controll() -> some View {
        HStack {
            FullSizeButton(title: "Abbrechen"){
                closeOverlay()
            }
            
            FullSizeButton(title: "Speichern") {
                animate = true
                
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
                    
                    DispatchQueue.main.async {
                       switch result {
                           case .success(let response):
                                print(response.description)
                                closeOverlay()
                           case .failure(let error):
                                print(error.localizedDescription)
                                showError(text: "Speichern fehlgeschlagen: \(error.localizedDescription)")
                       }
                   }
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
            animate = false
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            isPresented = false
        }
    }
    
    func closeOverlay() {
        animate = false
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            isPresented = false
        }
    }
    
    enum FocusedField {
        case name, description, preperation, preperationTime
    }
}

struct SaveOverlay: View {
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
        .padding(.horizontal, Theme.shared.padding * 2)
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
