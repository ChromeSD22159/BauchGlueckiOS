//
//  ShoppingListScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 03.11.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct ShoppingListScreen: View {
    private let theme: Theme = Theme.shared 
    
    @Query(animation: .easeInOut) var shoppingListItems: [ShoppingList]
    @State var ASC: Bool = false
    
    init(userId: String = Auth.auth().currentUser?.uid ?? "") {
        let predicate = #Predicate<ShoppingList> { list in
            list.isDeleted == false && list.userId == userId
        }
        
        self._shoppingListItems = Query(filter: predicate, animation: .easeInOut)
    }
    
    var sortedShoppingListItems: [ShoppingList] {
        if ASC {
            return self.shoppingListItems.sorted { $0.startDate > $1.startDate }
        } else {
            return self.shoppingListItems.sorted { $0.startDate < $1.startDate }
        }
    }
    
    var body: some View {
        ScreenHolder {
            ScrollView(.vertical, showsIndicators: false) {
                AddShoppingListCard()
                
                ShoppingList()
            }
        }
    }
    
    @ViewBuilder
    func ShoppingList() -> some View {
        if sortedShoppingListItems.count > 0 {
            HStack {
                HStack() {
                    Image(systemName: ASC ? "arrow.down" : "arrow.up")
                    Text("Sortierung")
                }
                .onTapGesture { ASC.toggle() }
                .padding(.leading, 5)
                
                Spacer()
            }
            .padding(theme.padding)
            .font(.footnote)
 
            ForEach(sortedShoppingListItems, id: \.self) { item in
                ShoppingListCard(shoppingList: item)
            }
            
            VStack {
              Text("⚠️ Wichtiger Hinweis: Ihre Einkaufsliste wird nicht automatisch aktualisiert, wenn Sie Ihre Einkaufsliste in der App vornehmen oder einen neuen Mealplan erstellen. Um sicherzustellen, dass Ihre Einkaufsliste alle benötigten Zutaten enthält, überprüfen sie Ihre Einkaufsliste regelmässig und erstellen Sie eine neue Liste.\nFür Fragen oder Unterstützung stehen wir Ihnen jederzeit zur Verfügung. Nutzen Sie den Support-Button unten in den Einstellungen.")
                    .font(.footnote)
            }
            .sectionShadow(innerPadding: theme.padding, margin: theme.padding)
            .padding(.bottom, theme.padding)
            
        } else {
            NoShopping()
                .padding(.bottom, theme.padding)
        }
    }
}
 

#Preview {
    @Previewable @State var debug = true
    ShoppingListScreen()
        .onTapGesture {
            debug.toggle()
        }
        .modelContainer(debug ? previewDataScource : localDataScource)
}
