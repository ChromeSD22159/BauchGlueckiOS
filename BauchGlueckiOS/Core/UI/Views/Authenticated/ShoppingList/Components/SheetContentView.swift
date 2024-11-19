//
//  SheetContentView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct SheetContentView: View {
    
    private let theme: Theme = Theme.shared
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var service: Services
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var saveOverlay: Bool
    let hasError: (Error?) -> Void
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
                    in: DateHelper.nextThirtyDays.first!...DateHelper.nextThirtyDays.last!,
                    displayedComponents: [.date]
                )
                .font(.footnote)
                .datePickerStyle(DefaultDatePickerStyle())
                
                DatePicker(
                    "End Datum",
                    selection: $endDate,
                    in: DateHelper.nextThirtyDays.first!...DateHelper.nextThirtyDays.last!,
                    displayedComponents: [.date]
                )
                .font(.footnote)
                .datePickerStyle(DefaultDatePickerStyle())
                
                Text("Gewählter Zeitraum: \(formattedDateRange())")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.footnote)
                
                Button(action: generateShoppingList, label: {
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
    
    private func generateShoppingList() {
        saveOverlay.toggle()

        service.mealPlanService.calculateShoppingList(
            startDate: startDate,
            endDate: endDate,
            context: modelContext
        ) { result in
            switch result {
                case .success(_):
                    Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: {_ in
                        saveOverlay.toggle()
                    })
                case .failure(let error):
                    hasError(error)
                    
                    Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: {_ in
                        saveOverlay.toggle()
                        hasError(nil)
                    })
            }
        }
    } 
    
    private func formattedDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let numberOfDays = daysBetween(startDate: startDate, endDate: endDate)
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate)) (\(numberOfDays) Tage)"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
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
    @Previewable @State var saveOverlay = true
    SheetContentView(startDate: $startDate, endDate: $endDate, saveOverlay: $saveOverlay) { _ in }
}
