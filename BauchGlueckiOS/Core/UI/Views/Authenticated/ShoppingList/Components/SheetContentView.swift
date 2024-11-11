//
//  SheetContentView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct SheetContentView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    private let theme: Theme = Theme.shared
    
    var body: some View {
        ZStack {
            Theme.shared.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text("Wähle deinen Einkaufszeitraum")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.headline).font(Theme.shared.headlineTextMedium)
                
                Text("Erstelle deine erste Einkaufsliste basierend auf deinem MealPlan!")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.footnote)
                
                DatePicker(
                    "Start Datum",
                    selection: $startDate,
                    in: DateService.nextThirtyDays.first!...DateService.nextThirtyDays.last!,
                    displayedComponents: [.date]
                )
                .datePickerStyle(DefaultDatePickerStyle())
                
                DatePicker(
                    "End Datum",
                    selection: $endDate,
                    in: DateService.nextThirtyDays.first!...DateService.nextThirtyDays.last!,
                    displayedComponents: [.date]
                )
                .datePickerStyle(DefaultDatePickerStyle())
                
                Text("Gewählter Zeitraum: \(formattedDateRange())")
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: {
                    // Handle confirmation
                }, label: {
                    Text("Bestätigen")
                        .foregroundStyle(Theme.shared.onPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                })
                .background(Theme.shared.backgroundGradient)
                .clipShape(Capsule())
            }
            .padding(.vertical, theme.padding * 2)
            .padding(.horizontal, 16)
        }
    }
    
    private func formattedDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let numberOfDays = daysBetween(startDate: startDate, endDate: endDate)
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate)) (\(numberOfDays) Tage)"
    }
    
    private func daysBetween(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
}

#Preview {
    @Previewable @State var startDate: Date = Date().startOfDate()
    @Previewable @State var endDate: Date =   Calendar.current.date(byAdding: .day, value: 1, to: Date().startOfDate())!
    SheetContentView(startDate: $startDate, endDate: $endDate)
}
