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

    @Query var medi: [Medication]
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
                    
                    if tab == .intake {
                        if medi.count > 0 {
                            
                        } else {
                            ForEach(medi.indices, id: \.self) { index in
                                MedicationCard(
                                    medication: medi[index],
                                    onDelete: {
                                        modelContext.delete(medi[index])
                                    }
                                )
                            }
                        }
                    }
                    
                    if tab == .history {
                        if medi.count > 0 {
                            
                        } else {
                            ForEach(medi.indices, id: \.self) { index in
                                MedicationHistoryCard(medication: medi[index])
                            }
                        }
                        
                    }
                    
                }
                .padding(theme.padding)
            }
        }
    }
    
    enum Tab {
        case intake, history
    }
}



