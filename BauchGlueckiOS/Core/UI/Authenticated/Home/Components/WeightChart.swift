//
//  WeightChart.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct WeightChart: View {
    @Query() var weights: [Weight]
    
    let theme: Theme = Theme.shared
    
    var gradient = LinearGradient(colors: [
        Theme.shared.primary.opacity(0.55),
        Theme.shared.primary.opacity(0.1)
    ], startPoint: .top, endPoint: .bottom)
    
    @State var weeklyAverage: [WeeklyAverage] = []
    
    let aufsteigend = true
    
    var body: some View {
        
        if weeklyAverage.isEmpty {
            HomeWeightMockCard()
                .padding(.horizontal, theme.padding)
        } else {
            VStack {
                HStack {
                    Image(systemName: aufsteigend ? "arrow.up.forward.circle.fill" : "arrow.down.forward.circle.fill")
                    
                    Text(aufsteigend ? "Aufsteigender" : "Absteigender" + " Trend")
                        .font(.footnote)
                     
                    Spacer()
                }   .foregroundStyle(theme.onBackground)
                
                HStack(alignment: .bottom, spacing: 15) {
                    ForEach(weeklyAverage, id: \.week) { week in
                        VStack(spacing: 15) {
                            Spacer()
                            
                            HStack(alignment: .bottom) {
                                Capsule()
                                    .frame(width: 25, height: calculateHeight(input: week.avgValue) )
                                    .foregroundStyle(theme.primary)
                            }
                            
                            HStack(alignment: .bottom) {
                                Text(week.week)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(theme.onBackground)
                                    .rotationEffect(Angle(degrees: -90))
                            }
                            .frame(height: 40)
                        }
                    }
                }
                .frame(height: 280)
            }
            .padding(theme.padding)
            .background(gradient)
            .cornerRadius(theme.radius)
            .padding(.horizontal, theme.padding)
            .onTapGesture {
                loadData()
            }
            .onAppLifeCycle(appearAndActive: {
                loadData()
            })
        }
        
        
    }
    
    private func loadData() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        let calendar = Calendar.current

        // Finde den nächsten Sonntag (Ende der Woche)
        let today = Date()
        guard let endOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))?.addingTimeInterval(6 * 24 * 60 * 60) else {
           return
        }
        
        let predicate = #Predicate<Weight> { weight in
                weight.userID == userID
        }
        
        let result = Query(filter: predicate)

        // Filtere die Ergebnisse und konvertiere die Daten
        var weeklyData: [Date: [Double]] = [:]
        
        // Filtere die abgerufenen Einträge nach dem Zeitraum der letzten 7 Wochen
        result.wrappedValue.forEach { weight in
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
        let weeklyAverages: [WeeklyAverage] = weeklyData.map { weekStart, weights in
            let avgWeight = weights.reduce(0, +) / Double(weights.count)
            return WeeklyAverage(avgValue: avgWeight, week: DateRepository.formatDateDDMM(date: weekStart))
        }
        
        // Sortiere die Wochen nach Datum
        let sortedWeeklyAverages = weeklyAverages.sorted { $0.week < $1.week }
        
        // Ausgabe der Ergebnisse
        self.weeklyAverage = sortedWeeklyAverages
    }
    
    private func calculateHeight(input: Double) -> Double {
        // Definiere die Mindest- und Maximalhöhe
        let minHeight: Double = 0
        let maxHeight: Double = 200

        // Normalisiere den Eingabewert auf den Bereich 0 bis 300
        let normalizedHeight = (input / 100) * maxHeight

        // Stelle sicher, dass die Höhe innerhalb des Bereichs 0 bis 300 bleibt
        return min(maxHeight, max(minHeight, normalizedHeight))
    }
}
