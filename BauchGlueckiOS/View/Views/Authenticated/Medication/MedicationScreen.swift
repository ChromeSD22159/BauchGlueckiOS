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
    @State var viewModel: MedicationViewModel
 
    init(services: Services) {
        self._viewModel = State(wrappedValue: ViewModelFactory.makeMedicationListViewModel(services: services))
    }
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: theme.layout.padding) {
                    
                    Picker("What is your favorite color?", selection: $viewModel.medicationViewTab) {
                        Label("Einnahme", systemImage: "pills.fill").tag(MedicationViewTab.intake)
                        Label("Verlauf", systemImage: "square.grid.2x2.fill").tag(MedicationViewTab.history)
                    }
                    .pickerStyle(.segmented)
                    
                    if !viewModel.userhasMedications {
                        NoMedCard()
                    } else {
                        if viewModel.medicationViewTab == .intake {
                            ForEach(viewModel.medications.indices, id: \.self) { index in
                                MedicationCard(medication: viewModel.getMedicationByIndex(index))
                                    .environmentObject(viewModel)
                            }
                        }
                        if viewModel.medicationViewTab == .history {
                            ForEach(viewModel.medications, id: \.self) { medication in
                                MedicationHistoryCard(medication: medication)
                            }
                        }
                    }
                }
                .padding(theme.layout.padding)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadMedications()
            }
        }
    }
}
