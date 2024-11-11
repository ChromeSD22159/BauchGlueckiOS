//
//  AddRecipeButtonWithPicker.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 08.11.24.
//
import SwiftUI

struct AddRecipeButtonWithPicker: View {
    let navTitle: String = "Rezept erstellen"
    @State var isRecipeSheet = false
    var body: some View {
        Button(action: {
            isRecipeSheet.toggle()
        }, label: {
           Image(systemName: "plus")
                .foregroundStyle(Theme.shared.onBackground)
        })
        .sheet(isPresented: $isRecipeSheet, onDismiss: {}, content: {
            NavigationView {
                AddRecipe(isPresented: $isRecipeSheet, navTitle: navTitle)
                    .presentationDragIndicator(.visible)
            }
        })
    }
}

#Preview("AddRecipeButtonWithPicker") {
    @Previewable @State var isRecipeSheet = false
    AddRecipeButtonWithPicker(isRecipeSheet: isRecipeSheet)
}
