//
//  SheetContentView.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct SheetContentView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var service: Services
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var saveOverlay: Bool
    
    let hasError: (Error?) -> Void
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text("Wähle deinen Einkaufszeitraum")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(theme.font.headlineTextMedium)
                
                FootLineText("Erstelle deine erste Einkaufsliste basierend auf deinem MealPlan!")
                    .frame(maxWidth: .infinity, alignment: .center) 
                
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
                 
                FootLineText("Gewählter Zeitraum: \(formattedDateRange())")
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: generateShoppingList, label: {
                    Text("Bestätigen")
                        .foregroundStyle(theme.color.onPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                })
                .background(theme.color.backgroundGradient)
                .clipShape(Capsule())
            }
            .padding(.vertical, theme.layout.padding * 2)
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
