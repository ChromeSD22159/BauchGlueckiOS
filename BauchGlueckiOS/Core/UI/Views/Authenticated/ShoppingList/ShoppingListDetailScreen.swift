//
//  ShoppingListDetailScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//
import SwiftUI
import SwiftData

struct ShoppingListDetailScreen: View {
    @Environment(\.modelContext) var modelContext
    @Query var shoppingList: [ShoppingList]
    
    init(shoppingListId: UUID) {
        let predicate = #Predicate<ShoppingList> { $0.id == shoppingListId }
        self._shoppingList = Query(filter: predicate)
    }
    
    var body: some View {
        if let shoppingList = shoppingList.first {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Shopping Liste")
                        .font(Theme.shared.headlineTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Alle Zutaten deines Mealplans im Zeitraum von \(shoppingList.startDate) bis \(shoppingList.endDate).")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: IngredientLIST
                    @Bindable var shoppingList: ShoppingList = shoppingList
                    IngredientListView(shoppingList: shoppingList)
                    
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                shoppingList.isComplete.toggle()
                            }
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
                    }.font(.footnote)
                }
                .padding(Theme.shared.padding)
            }
        }
    }
}

struct IngredientListView: View {
    @Bindable var shoppingList: ShoppingList

    var body: some View {
        VStack {
            Text("Zutaten")
                .font(Theme.shared.headlineTextSmall)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(shoppingList.items) { item in
                IngredientItem(shoppingList: shoppingList, ingredient: item)
            }
        }
        .font(.footnote)
    }
    
    @ViewBuilder func IngredientItem(shoppingList: ShoppingList, ingredient: ShoppingListItem) -> some View {
        HStack {
            Text(ingredient.name.uppercasedFirst())
            Spacer()
            Text("\(ingredient.amount) \(ingredient.unit)")
        }
        .padding(Theme.shared.padding)
        .foregroundStyle(
            Theme.shared.onBackground.opacity(shoppingList.isComplete ? 0.2 : ingredient.isComplete ?  0.2 : 1.0)
        )
        .sectionShadow(innerPadding: 5)
        .onTapGesture {
            withAnimation(.easeInOut) {
                ingredient.isComplete.toggle()
            }
        }
    }
}

extension String {
    func uppercasedFirst() -> String {
        prefix(1).uppercased() + dropFirst()
    }
}

#Preview {
    if let id = mockShoppingLists.first?.id {
        ShoppingListDetailScreen(shoppingListId: id)
            .modelContainer(previewDataScource)
    }
}
