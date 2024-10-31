//
//  Weights.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct WeightsScreen: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @State private var currentWeight: Double = 0.0
    @State private var weeklyAverage: [WeeklyAverageData] = []
    
    @Query() var weights: [Weight]
    
    private let theme: Theme = Theme.shared
    private var startWeight: Double
    private var totalWeightLost: Double {
        self.startWeight - self.currentWeight
    }
    
    init(startWeight: Double) {
        self.startWeight = startWeight
        
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<Weight> { weight in
            weight.userID == userID
        }
        
        self._weights = Query(
            filter: predicate,
            sort: \Weight.weighed
        )
    }
    
    var body: some View {
        ScreenHolder() {
            SectionVStack(header: "Totaler Gewichtsverlust") {
                HStack {
                    Text("Totaler Gewichtsverlust:")
                    Spacer()
                    Text(String(format: "%.1fkg", totalWeightLost))
                }
            }

            SectionVStack(header: "Totaler Gewichtsverlust" ) {
                VStack {
                    HStack {
                        Text("Differenz:")
                        Spacer()
                        Text(String(format: "%.1fkg", totalWeightLost))
                    }
                    
                    HStack {
                        Text(String(format: "Von: 18.10 zu 25.10"))
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            
            SectionVStack(header: "Gewichtsverlust Historie") {
                ForEach(weeklyAverage.indices, id: \.self) { index in
                    let (differenceString, difference) = calcDifferenceToWeekBefore(index: index)
                    let start = DateRepository.formatDateDDMM(date: weeklyAverage[index].startOfWeek)
                    let end = DateRepository.formatDateDDMM(date: weeklyAverage[index].endOfWeek)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Von: \(start) zu \(end):")
                            Spacer()
                            Text(" Ø \(String(format: "%.1f kg", difference))")
                        }
                        if index > 0 {
                            Text("Differenz zur Vorwoche: \(differenceString)")
                                .font(.footnote)
                                .foregroundColor(difference >= 0 ? .green : .red)
                        } else {
                            Text("Differenz zur Vorwoche: \(differenceString)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            getLastWeight()
            calculateWeeklyAverage()
        }
    }
    
    private func calcDifferenceToWeekBefore(index: Int) -> (differenceString: String, difference: Double) {
        let nan = (differenceString: "N/A", difference: 0.0)
        guard index < weeklyAverage.count, index >= 0 else {
            return nan
        }

        let average = weeklyAverage[index]

        if index > 0 {
            let previousAverage = weeklyAverage[index - 1].avgValue
            let diff = average.avgValue - previousAverage
            let formattedDiff = String(format: "%.1f", diff)
            return diff >= 0 ? (differenceString: "+\(formattedDiff) kg", difference: diff)  : (differenceString: "\(formattedDiff) kg", difference: diff)
        } else {
            return nan
        }
    }
    
    private func getLastWeight() {
        let sortedWeights = self.weights.sorted(by: { first, second in
            guard let firstDate = ISO8601DateFormatter().date(from: first.weighed), let secondDate = ISO8601DateFormatter().date(from: second.weighed) else { return false }
            return firstDate > secondDate
        })
        
        self.currentWeight = sortedWeights.first?.value ?? self.startWeight
    }
    
    private func calculateWeeklyAverage() {
        let calendar = Calendar.current

        // Finde den nächsten Sonntag (Ende der Woche)
        let today = Date()
        guard let endOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))?.addingTimeInterval(6 * 24 * 60 * 60) else {
            return
        }

        // Erstelle eine leere Liste für die letzten 7 Wochen beginnend von heute
        var weeklyData: [Date: [Double]] = [:]
        
        for weekOffset in 0..<7 {
            if let weekStartDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: endOfWeek),
               let mondayOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStartDate)) {
                weeklyData[mondayOfWeek] = []
            }
        }

        // Filtere die abgerufenen Einträge nach dem Zeitraum der letzten 7 Wochen
        weights.forEach { weight in
            if let weighedDate = ISO8601DateFormatter().date(from: weight.weighed) {
                // Finde den Start der Woche (Montag)
                guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weighedDate)) else {
                    return
                }

                // Berechne den Startdatum der letzten 7 Wochen
                if let sevenWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -7, to: endOfWeek),
                   weighedDate >= sevenWeeksAgo && weighedDate <= endOfWeek {
                    
                    // Füge den Gewichtseintrag zur richtigen Woche hinzu
                    weeklyData[startOfWeek, default: []].append(weight.value)
                }
            }
        }

        // Berechne das durchschnittliche Gewicht pro Woche und erstelle WeeklyAverage-Einträge
        let weeklyAverages: [WeeklyAverageData] = weeklyData.map { weekStart, weights in
            let avgWeight = weights.isEmpty ? 0.0 : weights.reduce(0, +) / Double(weights.count)
            let cal = Calendar.current
            let startOfNextWeek = cal.date(byAdding: .day, value: +7, to: weekStart)!
            let endOfWeek = cal.date(byAdding: .second, value: -1, to: startOfNextWeek)!
            return WeeklyAverageData(avgValue: avgWeight, startOfWeek: weekStart, endOfWeek: endOfWeek)
        }
        
        // Sortiere die Wochen nach Datum
        let sortedWeeklyAverages = weeklyAverages.sorted { $0.startOfWeek < $1.startOfWeek }
        
        // Ausgabe der Ergebnisse mit formatiertem Datum
        self.weeklyAverage = sortedWeeklyAverages.map { weeklyAverage in
            WeeklyAverageData(avgValue: weeklyAverage.avgValue, startOfWeek: weeklyAverage.startOfWeek, endOfWeek: weeklyAverage.endOfWeek)
        }
    }
}

struct WeeklyAverageData {
    var avgValue: Double
    var startOfWeek: Date
    var endOfWeek: Date
}

struct SectionOutterHeader: View {
    private var theme: Theme
    private var text: String
    
    init(text: String) {
        self.theme = Theme.shared
        self.text = text
    }
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
        .font(.footnote)
        .padding(.horizontal, theme.padding)
    }
}
struct SectionVStack<Content: View>: View {
    private var theme: Theme
    private var header: String?
    private var content: () -> Content
    private var horizontalPadding: CGFloat
    
    init(
        theme: Theme = Theme.shared,
        header: String? = nil,
        horizontalPadding: CGFloat = 10,
        content: @escaping () -> Content
    ) {
        self.header = header
        self.theme = theme
        self.content = content
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        VStack {
            if let header = header {
                SectionOutterHeader(text: header)
            }
            
            VStack {
                VStack {
                    content()
                }
            }
            .padding(theme.padding)
            .sectionShadow()
        }
        .padding(.horizontal, horizontalPadding)
    }
}
