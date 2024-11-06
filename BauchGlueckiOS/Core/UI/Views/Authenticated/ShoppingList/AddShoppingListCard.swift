//
//  AddShoppingListCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct AddShoppingListCard: View {
    let theme = Theme.shared
    
    var onClick: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            theme.surface
            
            Image(.bubbleRight)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(x: 5)
                .frame(maxWidth: 200, maxHeight: 200)
            
            HStack {
                Image(.magen)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 5)
                    .frame(maxWidth: 75, maxHeight: 75)
                
                Spacer()
            }
            
            addButton()
                
        }
        .frame(maxHeight: 200)
        .sectionShadow()
        .padding(.horizontal, theme.padding)
    }
    
    @ViewBuilder func addButton() -> some View {
        HStack {
            Text("Einkaufsliste erstellen")
            Image(systemName: "plus")
        }
        .font(.footnote)
        .padding(theme.padding)
        .onTapGesture { onClick() }
    }
}
