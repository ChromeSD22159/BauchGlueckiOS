//
//  Weights.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//

import SwiftUI 
import SwiftData

struct WeightsScreen: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @State private var viewModel: WeightViewModel?
    @State private var startWeight: Double
    
    private let theme: Theme = Theme.shared
     
    init(startWeight: Double) {
        self.startWeight = startWeight
    }
    
    var body: some View {
        
        ScreenHolder() {
            
            if let viewModel = viewModel {
                SectionVStack (
                    header: "Totaler Gewichtsverlust",
                    infoText: "Die Berechnung des Gesamtverlusts basiert auf Ihrem Startgewicht, das in den Einstellungen unter 'Profil' angepasst werden kann."
                ) {
                    HStack {
                        Text("Totaler Gewichtsverlust:")
                        Spacer()
                        Text(WeightFormatUtils.formatWeight(viewModel.totalWeightLost))
                    }
                }
                
                if let highest = viewModel.highestWeightLost {
                    SectionVStack(
                        header: "Größter Gewichtsverlust",
                        infoText: "Dies ist der größte gemessene Gewichtsverlust innerhalb eines Wochenintervalls. Er zeigt an, wie viel Gewicht Sie in der erfolgreichsten Woche verloren haben."
                    ) {
                        VStack {
                            HStack {
                                Text("Differenz:")
                                Spacer()
                                Text(WeightFormatUtils.formatWeight(highest.difference))
                                
                            }
                            
                            HStack {
                                Text(WeightFormatUtils.fromTillDateString(from: highest.startDate, till: highest.endDate))
                                    .font(.footnote)
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                if let lowest = viewModel.lowestWeightLost {
                    SectionVStack(
                        header: "Niedrigster Gewichtsverlust",
                        infoText: "Dies ist der niedrigste gemessene Gewichtsverlust innerhalb eines Wochenintervalls. Er zeigt die Woche, in der Ihr Fortschritt am geringsten war."
                    ) {
                        VStack {
                            HStack {
                                Text("Differenz:")
                                Spacer()
                               
                                Text(WeightFormatUtils.formatWeight(lowest.difference))
                            }
                            
                            HStack {
                                let from = DateService.formatDateDDMM(date: lowest.startDate)
                                let till = DateService.formatDateDDMM(date: lowest.endDate)
                                Text(String(format: "Von: \(from) zu \(till)"))
                                    .font(.footnote)
                                Spacer()
                            }
                        }
                    }
                }
                
                SectionVStack(header: "Gewichtsverlust Historie") {
                    VStack(spacing: theme.padding + 5) {
                        ForEach(viewModel.weeklyAverage.indices, id: \.self) { index in
                            
                            let (differenceString, difference, _,_) = viewModel.calcDifferenceToWeekBefore(index: index)
                            let start = DateService.formatDateDDMM(date: viewModel.weeklyAverage[index].startOfWeek)
                            let end = DateService.formatDateDDMM(date: viewModel.weeklyAverage[index].endOfWeek)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Von: \(start) zu \(end):")
                                    Spacer()
                                    Text(" Ø \(String(format: "%.1f kg", difference))") // TODO: REFACTOR
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
            }
        }
        .onAppear {
            if viewModel == nil {
                   viewModel = WeightViewModel(startWeight: startWeight, modelContext: modelContext)
                   viewModel?.inizialize()
            }
        }
    }
    
    
}

private struct SectionOutterHeader: View {
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

private struct SectionVStack<Content: View>: View {
    private var theme: Theme
    private var header: String?
    private var content: (() -> Content)
    private var infoText: String?
    private var horizontalPadding: CGFloat
    
    init(
        theme: Theme = Theme.shared,
        header: String? = nil,
        infoText: String? = nil,
        horizontalPadding: CGFloat = 10,
        content: @escaping () -> Content
    ) {
        self.header = header
        self.theme = theme
        self.content = content
        self.infoText = infoText
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        VStack(spacing: 8) {
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
            
            if let infoText = infoText {
                HStack {
                    Label(infoText, systemImage: "info")
                        .font(.caption2)
                    Spacer()
                }.padding(.horizontal, theme.padding + 5)
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
} 
