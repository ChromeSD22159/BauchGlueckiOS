//
//  ShoppingListCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct ShoppingListCard: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject var firebase: FirebaseService
    @Bindable var shoppingList: ShoppingList
    var body: some View {
        HStack {
            Image(systemName: !shoppingList.isComplete ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
            
            Text("\(shoppingList.startDate) - \(shoppingList.endDate)")
                .navigateTo(
                    firebase: firebase,
                    destination: Destination.shoppingList,
                    target: { ShoppingListDetailScreen(shoppingListId: shoppingList.id) }
                )
            
            Spacer()
            
            
            // Mark: DropDownMenu
            Menu(content: {
                Button(action: {
                    shoppingList.isComplete.toggle()
                }) {
                    if shoppingList.isComplete {
                        Label("Ausstehend", systemImage: "exclamationmark.triangle.fill")
                    } else {
                        Label("Erledigt", systemImage: "checkmark.seal.fill")
                    }
                }
                Button(action: {
                    shoppingList.isDeleted = true
                }) {
                    Label("Löschen", systemImage: "trash")
                }
            }, label: {
                ZStack {
                    Image(systemName: "ellipsis")
                }
                .frame(width: 25, height: 25)
            })
        }
        .foregroundStyle(theme.color.onBackground.opacity(!shoppingList.isComplete ? 1.0 : 0.2))
        .sectionShadow(innerPadding: theme.layout.padding, margin: theme.layout.padding)
    }
}

#Preview {
    ShoppingListCard(shoppingList: mockShoppingLists.first!)
        .environmentObject(FirebaseService())
}
