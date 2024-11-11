//
//  ShoppingListDetailScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//
import SwiftUI

struct ShoppingListDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Binding var shoppingList: ShoppingList
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Shopping Liste")
                    .font(Theme.shared.headlineTextMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Alle Zutaten deines Mealplans im Zeitraum von \(shoppingList.startDate) bis \(shoppingList.endDate).")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("Zutaten")
                        .font(Theme.shared.headlineTextSmall)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(shoppingList.items) { item in
                        HStack {
                            Text("Zutat \(item.name)")
                            Spacer()
                            Text("\(item.amount) \(IngredientUnit.fromString(item.unit).unit)")
                        }
                        .sectionShadow(innerPadding: Theme.shared.padding)
                    }
                }
                
                HStack {
                    Button(action: {
                        shoppingList.isComplete.toggle()
                    }, label: {
                        if shoppingList.isComplete {
                            Label("Ausstehend", systemImage: "exclamationmark.triangle.fill")
                        } else {
                            Label("Erledigt", systemImage: "checkmark.seal.fill")
                        }
                    })
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(Theme.shared.onPrimary)
                    .background(Theme.shared.backgroundGradient)
                    .clipShape(Capsule())
                    
                    Button(action: {
                        shoppingList.isDeleted = true
                    }, label: {
                        Label("Löschen", systemImage: "trash")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .foregroundStyle(Theme.shared.onPrimary)
                    .background(Theme.shared.backgroundGradient)
                    .clipShape(Capsule())
                }
            }
            .padding(Theme.shared.padding)
        }
        
        
        
        // nicht erledigt     löschen
    }
}

#Preview {
    @Previewable @State var shoppingList = ShoppingList(
        name: "Test",
        descriptionText: "Test",
        startDate: "10.11.24",
        endDate: "11.11.24",
        items: [
            ShoppingListItem(
                name: "Zutat 1",
                amount: "1",
                unit: IngredientUnit.gramm.rawValue
            ),
            ShoppingListItem(
                name: "Zutat 2",
                amount: "5",
                unit: IngredientUnit.stueck.rawValue
            )
        ]
    )
    ShoppingListDetailScreen(shoppingList: $shoppingList)
}
