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
    
    private let theme: Theme = Theme.shared
    
    private var gradient = LinearGradient(colors: [
        Theme.shared.primary.opacity(0.55),
        Theme.shared.primary.opacity(0.1)
    ], startPoint: .top, endPoint: .bottom)
    
    @State private var weeklyAverage: [WeeklyAverage] = []
    @State private var animatedWeeklyAverage: [WeeklyAverage] = []
    
    var isAscendingTrend: Bool {
        guard weeklyAverage.count == 7 else {
            return false
        }
        
        var ascendingCount = 0
        var descendingCount = 0
 
        for i in 0..<weeklyAverage.count - 1 {
            if weeklyAverage[i].avgValue < weeklyAverage[i + 1].avgValue {
                ascendingCount += 1
            } else if weeklyAverage[i].avgValue > weeklyAverage[i + 1].avgValue {
                descendingCount += 1
            }
        }
 
        if ascendingCount > descendingCount {
            return true
        }  else {
            return false
        }
    }
    
    init() {
        let userID = Auth.auth().currentUser?.uid ?? ""
                
        let predicate = #Predicate<Weight> { weight in
            weight.userId == userID && weight.isDeleted == false
        }
        
        let fetch = Query(filter: predicate)
        
        self._weights = fetch
    }
    
    var body: some View {
        ZStack {
            
            if weights.count == 0 {
                HomeWeightMockCard()
                    .padding(.horizontal, theme.padding)
            } else {
                VStack {
                    HStack {
                        Image(systemName: isAscendingTrend ? "arrow.up.forward.circle.fill" : "arrow.down.forward.circle.fill")
                        
                        Text(isAscendingTrend ? "Aufsteigender" : "Absteigender" + " Trend")
                            .font(.footnote)
                         
                        Spacer()
                    }
                    .foregroundStyle(theme.onBackground)
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(animatedWeeklyAverage, id: \.week) { week in
                            VStack(spacing: 30) {
                                Spacer()
                                
                                HStack(alignment: .bottom) {
                                    Capsule()
                                        .frame(width: 25, height: calculateHeight(input: week.avgValue) )
                                        .foregroundStyle(theme.primary)
                                }
                                
                                HStack(alignment: .bottom) {
                                    Text(DateService.formatDateDDMM(date: week.week))
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(theme.onBackground)
                                        .rotationEffect(Angle(degrees: -90))
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(height: 40)
                            }
                        }
                    }
                    .opacity(0.5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                }
                .padding(theme.padding)
                .padding(theme.padding)
                .background(gradient)
                .cornerRadius(theme.radius)
                .padding(.horizontal, theme.padding)
                .onAppLifeCycle(appearAndActive: calculateWeeklyAverage)
            }
        }
    }
    
    private func calculateHeight(input: Double) -> Double {
        // Definiere die Mindest- und Maximalhöhe
        let minHeight: Double = 0
        let maxHeight: Double = 200

        // Normalisiere den Eingabewert auf den Bereich 0 bis 200
        let normalizedHeight = (input / 100) * maxHeight
        
        // Stelle sicher, dass die Höhe innerhalb des Bereichs 0 bis 200 bleibt
        return min(maxHeight, max(minHeight, normalizedHeight))
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
            guard let weighedDate = weight.toDate(),
                  let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weighedDate)) else {
                return
            }

            if let sevenWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -7, to: endOfWeek),
               weighedDate >= sevenWeeksAgo && weighedDate <= endOfWeek {
                weeklyData[startOfWeek, default: []].append(weight.value)
            }
        }

        // Berechne das durchschnittliche Gewicht pro Woche und erstelle WeeklyAverage-Einträge
        let weeklyAverages: [WeeklyAverage] = weeklyData.map { weekStart, weights in
            let avgWeight = weights.isEmpty ? 0.0 : weights.reduce(0, +) / Double(weights.count)
            return WeeklyAverage(avgValue: avgWeight, week: weekStart)
        }
        
        // Sortiere die Wochen nach Datum
        let sortedWeeklyAverages = weeklyAverages.sorted { $0.week < $1.week }
        
        self.weeklyAverage = sortedWeeklyAverages.map { weeklyAverage in
            WeeklyAverage(avgValue: weeklyAverage.avgValue , week: weeklyAverage.week)
        }
        
        self.animatedWeeklyAverage = sortedWeeklyAverages.map { weeklyAverage in
            WeeklyAverage(avgValue: 0.0, week: weeklyAverage.week)
        }
        
        for i in 0..<weeklyAverage.count {
           DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
               withAnimation(.easeIn(duration: 0.25)) {
                   animatedWeeklyAverage[i].avgValue = sortedWeeklyAverages[i].avgValue
               }
           }
       }
    }
}


// TODO: REDACTOR
extension Weight {
    func toDate() -> Date? {
       let dateFormatter = ISO8601DateFormatter()
       dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return dateFormatter.date(from: self.weighed)
    }
}
