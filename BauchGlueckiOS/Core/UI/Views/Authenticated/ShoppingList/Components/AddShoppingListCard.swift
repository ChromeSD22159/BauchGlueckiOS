//
//  AddShoppingListCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct AddShoppingListCard: View {
    let theme = Theme.shared
    
    @State var startDate: Date
    @State var endDate: Date
    @State var showSheet: Bool = false
    @Binding var saveOverlay: Bool
    
    @Binding var hasError: Error?
    
    init(hasError: Binding<Error?>, saveOverlay: Binding<Bool>) {
        let cal = Calendar.current
        self.startDate = Date().startOfDate()
        let endDate = cal.date(byAdding: .day, value: 1, to: Date().startOfDate())!
        self.endDate = endDate.endOfDay()
        self._saveOverlay = saveOverlay
        self._hasError = hasError
    }
    
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
        .sheet(isPresented: $showSheet, content: {
            SheetContentView(startDate: $startDate, endDate: $endDate, saveOverlay: $saveOverlay, hasError: setError)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        })
    }
    
    @ViewBuilder func addButton() -> some View {
        HStack {
            Text("Einkaufsliste erstellen")
            Image(systemName: "plus")
        }
        .font(.footnote)
        .padding(theme.padding)
        .onTapGesture { showSheet.toggle() }
    }
    
    private func setError(_ error: Error?) {
        hasError = error
    }
}

#Preview {
    AddShoppingListCard(hasError: .constant(nil), saveOverlay: .constant(true))
}
