//
//  ShoppingListCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct ShoppingListCard: View {
    private let theme: Theme = Theme.shared
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
        .foregroundStyle(Theme.shared.onBackground.opacity(!shoppingList.isComplete ? 1.0 : 0.2))
        .sectionShadow(innerPadding: theme.padding, margin: theme.padding)
    }
}

#Preview {
    ShoppingListCard(shoppingList: mockShoppingLists.first!)
        .environmentObject(FirebaseService())
}
