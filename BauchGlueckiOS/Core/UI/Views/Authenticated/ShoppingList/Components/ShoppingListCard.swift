//
//  ShoppingListCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct ShoppingListCard: View {
    private let theme: Theme = Theme.shared 
    @Bindable var shoppingList: ShoppingList
    var body: some View {
        HStack {
            Text("\(shoppingList.startDate) - \(shoppingList.endDate)")
            Spacer()
            
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
                Image(systemName: "ellipsis")
            })
        }
        .foregroundStyle(Theme.shared.onBackground)
        .sectionShadow(innerPadding: theme.padding, margin: theme.padding)
    }
}

#Preview {
    ShoppingListCard(shoppingList: mockShoppingLists.first!)
}
