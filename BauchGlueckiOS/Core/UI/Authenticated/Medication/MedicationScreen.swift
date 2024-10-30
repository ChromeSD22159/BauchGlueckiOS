//
//  MedicationScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

struct MedicationScreen: View {
    let theme: Theme = Theme.shared

    @Query(sort: \Medication.name, order: .forward) var medication: [Medication]
    
    var filterIntakeTimeStatusesForToday: [Medication] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let new = medication.map { medi in
            // Filter intakeTimes for each medication
            let intakeTimes = medi.intakeTimes.map { time in
                let updatedTime = time
                updatedTime.intakeStatuses = time.intakeStatuses.filter { status in
                    !status.isDeleted && calendar.isDate(status.date.toDate, inSameDayAs: today)
                }
                return updatedTime
            }
            
            // Rückgabe des Medikaments mit den gefilterten intakeTimes
            let updatedMedication = medi
            updatedMedication.intakeTimes = intakeTimes
            return updatedMedication
        }
        
        return new
    }
    
    @State private var tab: Tab = .intake
    @Environment(\.modelContext) var modelContext
 
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: theme.padding) {
                    
                    Picker("What is your favorite color?", selection: $tab) {
                        Label("Einnahme", systemImage: "pills.fill").tag(Tab.intake)
                        Label("Verlauf", systemImage: "square.grid.2x2.fill").tag(Tab.history)
                    }
                    .pickerStyle(.segmented)
                    
                    if medication.count == 0 {
                        NoMedCard()
                    } else {
                        if tab == .intake {
                            ForEach(medication.indices, id: \.self) { index in
                                MedicationCard(
                                    medication: medication[index],
                                    onDelete: { delete(index: index) }
                                )
                            }
                        }
                        if tab == .history {
                            ForEach(medication.indices, id: \.self) { index in
                                MedicationHistoryCard(medication: medication[index])
                            }
                        }
                    }
                }
                .padding(theme.padding)
            }
        }
    }
    
    func delete(index: Int) {
        modelContext.delete(medication[index])
    }
    
    enum Tab {
        case intake, history
    }
}
