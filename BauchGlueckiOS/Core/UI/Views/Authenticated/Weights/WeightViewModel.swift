//
//  WeightViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.11.24.
//

import SwiftData
import Foundation
import FirebaseAuth

@Observable
class WeightViewModel: ObservableObject {
    private var modelContext: ModelContext
    
    var weights: [Weight] = []
    var weeklyAverage: [WeeklyAverageData] = []
    var highestWeightLost: (differenceString: String, difference: Double, startDate: Date, endDate: Date)? = nil
    var lowestWeightLost: (differenceString: String, difference: Double, startDate: Date, endDate: Date)? = nil
    var currentWeight: Double = 0.0
    var startWeight: Double
    
    var totalWeightLost: Double {
        self.startWeight - self.currentWeight
    }
    
    init(startWeight: Double, modelContext: ModelContext) {
        self.startWeight = startWeight
        self.modelContext = modelContext
        
        self.weights = loadWeights()
    }
    
    func inizialize() {
        getLastWeight()
        
        let lastSevenWeeksData = self.calculateWeeklyAverage(weeks: 7)
        let lastFourteenWeeksData = self.calculateWeeklyAverage(weeks: 7)
        
        self.weeklyAverage = lastSevenWeeksData
        self.findLowestAndHeighestWeightLost(data: lastFourteenWeeksData)
    }
    
    func loadWeights() -> [Weight] {
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<Weight> { weight in
            weight.userId == userId
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getLastWeight() {
        let sortedWeights = self.weights.sorted(by: { first, second in
            guard let firstDate = ISO8601DateFormatter().date(from: first.weighed), let secondDate = ISO8601DateFormatter().date(from: second.weighed) else { return false }
            return firstDate > secondDate
        })
        
        self.currentWeight = sortedWeights.first?.value ?? self.startWeight
    }
    
    func calcDifferenceToWeekBefore(index: Int) -> (differenceString: String, difference: Double, startDate: Date, endDate: Date) {
        let nan = (differenceString: "N/A", difference: 0.0, startDate: Date(), endDate: Date())
        
        guard index < weeklyAverage.count, index >= 0 else {
            return nan
        }

        let currentAverage = weeklyAverage[index].avgValue
        var previousIndex = index - 1
        
        // Finde die letzte Woche mit Daten
        while previousIndex >= 0 && weeklyAverage[previousIndex].avgValue == 0 {
            previousIndex -= 1
        }

        // Wenn keine vorherige Woche mit Daten gefunden wurde
        guard previousIndex >= 0 else {
            return nan
        }

        let previousAverage = weeklyAverage[previousIndex].avgValue

        // Differenz berechnen
        let diff = currentAverage - previousAverage
        let formattedDiff = String(format: "%.1f", diff)
        
        // Falls aktuelle Woche keine Daten hat, aber Vorwoche hatte
        if currentAverage == 0 {
            return (differenceString: "+0.0 kg", difference: weeklyAverage[previousIndex].avgValue, startDate: weeklyAverage[previousIndex].startOfWeek, endDate: weeklyAverage[previousIndex].endOfWeek)
        }

        // Standardfälle: Differenz anzeigen
        if diff >= 0 {
            return (differenceString: "+\(formattedDiff) kg", difference: diff, startDate: weeklyAverage[previousIndex].startOfWeek, endDate: weeklyAverage[previousIndex].endOfWeek)
        } else {
            return (differenceString: "\(formattedDiff) kg", difference: weeklyAverage[index].avgValue, startDate: weeklyAverage[previousIndex].startOfWeek, endDate: weeklyAverage[previousIndex].endOfWeek)
        }
    }
    
    func findLowestAndHeighestWeightLost(data: [WeeklyAverageData]) {
        var differences: [(differenceString: String, difference: Double, startDate: Date, endDate: Date)] = []
        for (index, _) in data.enumerated() {
            differences.append(calcDifferenceToWeekBefore(index: index))
        }
        
        let descending = differences.sorted(by: { $0.difference > $1.difference })
        highestWeightLost = descending.first
        let ascending = differences.sorted(by: { $0.difference < $1.difference })
        lowestWeightLost = ascending.first
    }
    
    func calculateWeeklyAverage(weeks: Int) -> [WeeklyAverageData] {
        let calendar = Calendar.current

        // Finde den nächsten Sonntag (Ende der Woche)
        let today = Date()
        guard let endOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))?.addingTimeInterval(6 * 24 * 60 * 60) else {
            return []
        }

        // Erstelle eine leere Liste für die letzten 7 Wochen beginnend von heute
        var weeklyData: [Date: [Double]] = [:]
        
        for weekOffset in 0..<weeks {
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

            // Berechne den Startdatum der letzten 7 Wochen
            if let sevenWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -7, to: endOfWeek),
               weighedDate >= sevenWeeksAgo && weighedDate <= endOfWeek {
                
                // Füge den Gewichtseintrag zur richtigen Woche hinzu
                weeklyData[startOfWeek, default: []].append(weight.value)
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
        return sortedWeeklyAverages.map { weeklyAverage in
            WeeklyAverageData(avgValue: weeklyAverage.avgValue, startOfWeek: weeklyAverage.startOfWeek, endOfWeek: weeklyAverage.endOfWeek)
        }
    }
}
