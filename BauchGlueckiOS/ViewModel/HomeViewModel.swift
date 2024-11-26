//
//  HomeViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 25.11.24.
//
import SwiftUI
import FirebaseAuth
import SwiftData
 
@Observable
class HomeViewModel: ObservableObject {
    let context: ModelContext
    
    // MARK: - Sheet States
    var isSettingSheet: Bool = false
    var isUserProfileSheet: Bool = false
    
    
    // MARK: - WEIGHTS Data
    var weights: [Weight] = []
    var weeklyAverage: [WeeklyAverage] = []
    var animatedWeeklyAverage: [WeeklyAverage] = []
    
    // MARK: - Inizialize
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - WEIGHTS
    func fetchWeights() {
        Task {
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            let predicate = #Predicate<Weight> { weight in
                weight.userId == userID && weight.isDeleted == false
            }
            
            let fetchDescriptor = FetchDescriptor<Weight>(
                predicate: predicate
            )
            
            do {
                // Perform the fetch in the appropriate thread
                let results = try await MainActor.run {
                    try self.context.fetch(fetchDescriptor)
                }
                
                // Update weights on the main thread
                await MainActor.run {
                    self.weights = results
                }
            } catch {
                // Handle error on the main thread
                await MainActor.run {
                    self.weights = []
                }
                print("Error fetching weights: \(error)")
            }
        }
    }
    
    func calculateWeeklyAverage() {
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
                   self.animatedWeeklyAverage[i].avgValue = sortedWeeklyAverages[i].avgValue
               }
           }
       }
    }
    
    var isAscendingWeightTrend: Bool {
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
    
    
    // MARK: - Sheets
    func openOnboardingSheetWhenNoProfileIsGiven() {
        Task {
            do {
                let _ = try await FirebaseService.checkUserProfilExist()
            } catch {
                isUserProfileSheet = true
            }
        }
    }
    
    func toggleSettingSheet() {
        isSettingSheet = !isSettingSheet
    }
}
