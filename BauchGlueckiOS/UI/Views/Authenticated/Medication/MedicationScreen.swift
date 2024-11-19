//
//  MedicationScreen.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct MedicationScreen: View {
    @Environment(\.theme) private var theme

    @Query(sort: \Medication.name, order: .forward) var medication: [Medication]
    
    @State private var tab: Tab = .intake
    @Environment(\.modelContext) var modelContext
 
    init() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        _medication = Query(
            filter: #Predicate<Medication> { med in
                med.userId == userID
            }
        )
    }
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: theme.layout.padding) {
                    
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
                                    onDelete: {
                                        MedicationDataService.delete(context: modelContext, medication: medication[index])
                                    }
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
                .padding(theme.layout.padding)
            }
        }
    }
    
    enum Tab {
        case intake, history
    }
}
