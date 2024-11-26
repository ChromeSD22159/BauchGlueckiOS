//
//  Weights.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//

import SwiftUI 
import SwiftData

@MainActor
struct WeightsScreen: View {
    @Environment(\.theme) private var theme
    var modelContext: ModelContext
    
    @EnvironmentObject var viewModel: WeightViewModel
    @State private var startWeight: Double
     
    @MainActor
    init(startWeight: Double) {
        self.startWeight = startWeight
        self.modelContext = localDataScource.mainContext
    }
    
    var body: some View {
        
        ScreenHolder() {
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
                            Text(String(format: "Von: \(lowest.startDate.formatDateDDMM) zu \(lowest.endDate.formatDateDDMM)"))
                                .font(.footnote)
                            Spacer()
                        }
                    }
                }
            }
            
            SectionVStack(header: "Gewichtsverlust Historie") {
                VStack(spacing: theme.layout.padding + 5) {
                    ForEach(viewModel.weeklyAverage.indices, id: \.self) { index in
                        
                        let (differenceString, difference, _, _) = viewModel.calcDifferenceToWeekBefore(index: index)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(DateFormatteUtil.fromTillString(from: viewModel.weeklyAverage[index].startOfWeek, till: viewModel.weeklyAverage[index].endOfWeek))
                                Spacer()
                                
                                Text(WeightFormatUtils.formatAvgWeightInKG(difference))
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
        .onAppear {
            self.viewModel.setStartWeight(self.startWeight)
            self.viewModel.inizialize()
        }
    }
}

private struct SectionOutterHeader: View {
    @Environment(\.theme) private var theme
    private var text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
        .font(.footnote)
        .padding(.horizontal, theme.layout.padding)
    }
}

private struct SectionVStack<Content: View>: View {
    @Environment(\.theme) private var theme
    private var header: String?
    private var content: (() -> Content)
    private var infoText: String?
    private var horizontalPadding: CGFloat
    
    init(
        header: String? = nil,
        infoText: String? = nil,
        horizontalPadding: CGFloat = 10,
        content: @escaping () -> Content
    ) {
        self.header = header
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
            .padding(theme.layout.padding)
            .sectionShadow()
            
            if let infoText = infoText {
                HStack {
                    Label(infoText, systemImage: "info")
                        .font(.caption2)
                    Spacer()
                }.padding(.horizontal, theme.layout.padding + 5)
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
} 
