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
    @State var sorting: Bool = false
    @State var saveOverlay: Bool = false
    @State var hasError: Error? = nil
    
    init(userId: String = Auth.auth().currentUser?.uid ?? "") {
        let predicate = #Predicate<ShoppingList> { list in
            list.isDeleted == false && list.userId == userId
        }
        
        self._shoppingListItems = Query(filter: predicate, animation: .easeInOut)
    }
    
    var sortedShoppingListItems: [ShoppingList] {
        if sorting {
            return self.shoppingListItems.sorted { $0.startDate > $1.startDate }
        } else {
            return self.shoppingListItems.sorted { $0.startDate < $1.startDate }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScreenHolder {
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        AddShoppingListCard(
                            hasError: $hasError,
                            saveOverlay: $saveOverlay
                        )
                         
                        ShoppingListView(
                            sortedShoppingListItems: sortedShoppingListItems,
                            asc: $sorting,
                            hasError: $hasError,
                            saveOverlay: $saveOverlay
                        )
                    }
                    
                    ShoppingListSaveOverlay(geo: geo, hasError: hasError, isPresented: $saveOverlay)
                }
            }
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
