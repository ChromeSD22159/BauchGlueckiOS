//
//  ShoppingListView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 11.11.24.
//
import SwiftUI

struct ShoppingListView: View {
    @Environment(\.theme) private var theme
    
    let sortedShoppingListItems: [ShoppingList]
    
    @Binding var asc: Bool
    @Binding var hasError: Error?
    @Binding var saveOverlay: Bool
    
    var body: some View {
        if sortedShoppingListItems.count > 0 {
            HStack {
                HStack() {
                    Image(systemName: asc ? "arrow.down" : "arrow.up").font(.footnote)
                    FootLineText("Sortierung")
                }
                .onTapGesture { asc.toggle() }
                .padding(.leading, 5)
                
                Spacer()
            }
            .padding(theme.layout.padding)
 
            ForEach(sortedShoppingListItems, id: \.self) { item in
                
                ShoppingListCard(shoppingList: item)
                
            }
            
            VStack {
                FootLineText("⚠️ Wichtiger Hinweis: Ihre Einkaufsliste wird nicht automatisch aktualisiert, wenn Sie Ihre Einkaufsliste in der App vornehmen oder einen neuen Mealplan erstellen. Um sicherzustellen, dass Ihre Einkaufsliste alle benötigten Zutaten enthält, überprüfen sie Ihre Einkaufsliste regelmässig und erstellen Sie eine neue Liste.\nFür Fragen oder Unterstützung stehen wir Ihnen jederzeit zur Verfügung. Nutzen Sie den Support-Button unten in den Einstellungen.") 
            }
            .sectionShadow(innerPadding: theme.layout.padding, margin: theme.layout.padding)
            .padding(.bottom, theme.layout.padding)
            
        } else {
            NoShopping(saveOverlay: $saveOverlay, hasError: setError)
            .padding(.bottom, theme.layout.padding)
        }
    }
    
    func setError(_ error: Error?) {
        self.hasError = error
    }
}

#Preview {
    ShoppingListView(sortedShoppingListItems: [], asc: .constant(true), hasError: .constant(nil), saveOverlay: .constant(false))
}
