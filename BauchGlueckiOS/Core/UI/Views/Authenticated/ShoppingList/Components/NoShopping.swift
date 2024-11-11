//
//  NoShopping.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 10.11.24.
//
import SwiftUI

struct NoShopping: View {
    private let theme: Theme = Theme.shared
    @State var startDate: Date
    @State var endDate: Date
    @State var showSheet: Bool = false
    
    init() {
        let cal = Calendar.current
        self.startDate = Date().startOfDate()
        let endDate = cal.date(byAdding: .day, value: 1, to: Date().startOfDate())!
        self.endDate = endDate.endOfDay()
    }
    
    let dateRange: ClosedRange<Date> = {
        let dates = DateService.nextThirtyDays
        
        return dates.first!...dates.last!
   }()
    
    var body: some View {
        HStack {
            Text("Erstelle deine erste Einkaufsliste basierend auf deinem MealPlan!")
        }
        .onTapGesture {
            showSheet.toggle()
        }
        .sectionShadow(innerPadding: theme.padding, margin: theme.padding)
        .sheet(isPresented: $showSheet, content: {
            SheetContentView(startDate: $startDate, endDate: $endDate)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        })
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
    NoShopping()
} 
