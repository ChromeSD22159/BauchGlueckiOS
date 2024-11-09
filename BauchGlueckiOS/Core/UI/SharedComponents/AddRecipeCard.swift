//
//  AddRecipeCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 08.11.24.
//
import SwiftUI

struct AddRecipeCard: View {
    let navTitle: String = "Rezept erstellen"
    @State var isRecipeSheet = false
    var body: some View {
        HStack {
            Text("Add Recipe")
        }
        .background(Theme.shared.surface)
        .sectionShadow(innerPadding: 10, margin: 10)
        .navigationTitle("Add Recipe")
        .onTapGesture { isRecipeSheet.toggle() }
        .sheet(isPresented: $isRecipeSheet, onDismiss: {}, content: {
            NavigationView {
                AddRecipe(isPresented: $isRecipeSheet, navTitle: navTitle)
                .presentationDragIndicator(.visible)
            }
        })
    }
}
#Preview("AddRecipeCard") {
    @Previewable @State var isRecipeSheet = false
    
    AddRecipeCard(isRecipeSheet: isRecipeSheet)
}
