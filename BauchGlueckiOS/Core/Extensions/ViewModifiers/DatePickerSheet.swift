//
//  DatePickerSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 06.11.24.
//
import SwiftUI

#Preview {
    @Previewable @State var isSheet = true
    VStack {
        Button("OpenSheet") {
            isSheet.toggle()
        }
    }
    .datePickerSheet(isSheet: $isSheet) { date in
        
    }
}

extension View {
    func datePickerSheet(isSheet: Binding<Bool>, onDateSelect: @escaping (Date) -> Void) -> some View {
        modifier(DatePickerSheet(isSheet: isSheet, onDateSelect: onDateSelect))
    }
}

struct DatePickerSheet: ViewModifier {
    @State private var date: Date = Date()
    
    var isSheet: Binding<Bool>
    var onDateSelect: (Date) -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: isSheet,
                onDismiss: {
                    // Optional: add logic for when the sheet is dismissed
                },
                content: {
                    VStack {
                        let dateRange = DateService.nextThirtyDays
                        
                        DatePicker(
                            "Start Date",
                            selection: $date,
                            in: dateRange.first!...dateRange.last!,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .presentationDragIndicator(.visible)
                        .tint(Theme.shared.primary)
                        
                        Button(action: {
                            isSheet.wrappedValue.toggle()
                            
                            onDateSelect(date)
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Bestätigen")
                                Spacer()
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 10)
                            .foregroundStyle(Theme.shared.onPrimary)
                            .background(Theme.shared.backgroundGradient)
                            .clipShape(Capsule())
                            .padding(.horizontal, 10)
                        })
                    }
                    .presentationDetents([.medium])
                }
            )
    }
}
