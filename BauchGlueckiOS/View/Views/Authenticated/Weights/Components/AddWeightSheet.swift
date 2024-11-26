//
//  AddWeightSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct AddWeightSheetButton: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject var services: Services
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var weightViewModel: WeightViewModel
    
    @State private var isSheet = false
    
    var startWeight: Double
    
    var body: some View {
        Button(
            action: {
                isSheet.toggle()
            }, label: {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent.badge.plus")
                    .foregroundStyle(theme.color.onBackground)
            }
        )
        .sheet(isPresented:$isSheet) {
            SheetHolder(title: "Gewicht eintragen") {
                let config = AppConfig.shared.weightConfig
                
                AddWeightSheetContent(
                    durationRange: config.weightRange,
                    stepsEach: config.stepsEach,
                    steps: config.stepsInSeconds,
                    startWeight: startWeight,
                    close: {
                        isSheet.toggle()
                        updateBackend()
                    }
                )
            }
        }
    }
    
    private func updateBackend() {
        services.weightService.sendUpdatedWeightsToBackend()
        homeViewModel.fetchWeights()
        weightViewModel.inizialize()
    }
}

struct AddWeightSheetContent: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @Environment(\.theme) private var theme
    @EnvironmentObject var services: Services
    @EnvironmentObject var errorHandling: ErrorHandling
    
    // FormStates
    @State private var currentWeight: Double = 90.0
    @State var lastWeight: Double = 1.0

    private var startWeight: Double
    private var durationRange: ClosedRange<Double>
    private var stepsEach: Double
    private var steps: [Double]
    private var close: () -> Void
    
    init(
        durationRange: ClosedRange<Double>,
        stepsEach: Double,
        steps: [Double],
        startWeight: Double,
        close: @escaping () -> Void
    ) {
        self.durationRange = durationRange
        self.stepsEach = stepsEach
        self.steps = steps
        self.currentWeight = startWeight
        self.startWeight = startWeight
        self.close = close
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            VStack {
                Image(.magen)
                    .resizable()
                    .frame(width: 150, height: 150) 
                
                Text("Neues Gewicht hinzufügen")
                    .font(theme.font.headlineText)
                    .foregroundStyle(theme.color.primary)
            }
            
            ZStack(alignment: .bottom) {
                VStack {
                    let weightDifferenceSigned = abs(currentWeight - lastWeight)
                    let weightDifferenceUnsigned = currentWeight - lastWeight
                                    
                    Gauge(value: weightDifferenceSigned, in: 0...abs(lastWeight)) {
                        Image(systemName: "gauge.medium")
                            .font(.system(size: 50.0))
                    } currentValueLabel: {
                        VStack {
                            Text("\(currentWeight.formatted(.number))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(theme.color.onPrimary)
                            
                            if weightDifferenceUnsigned == 0.0 {
                                DifferenceText(string: "\(weightDifferenceSigned.formatted(.number))")
                            } else if weightDifferenceUnsigned > 0.0 {
                                DifferenceText(string: "\("+")\(weightDifferenceSigned.formatted(.number))")
                            } else {
                                DifferenceText(string: "\("-")\(weightDifferenceSigned.formatted(.number))")
                            }
                        }
                    }
                    .gaugeStyle(WeightOmeterGaugeStyle())
                    Spacer()
                }
                
                HStack {
                    Button(action: {
                        increaseWeight()
                    }, label: {
                        Image(systemName: "minus")
                            .font(.headline)
                            .padding(theme.layout.padding)
                            .frame(height: 35)
                    })
                    .frame(minWidth: 60)
                    .foregroundStyle(theme.color.onPrimary)
                    .background(theme.color.backgroundGradient)
                    .cornerRadius(100)
                    
                    Spacer()
                    
                    Button(action: {
                        decreaseWeight()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .padding(theme.layout.padding)
                            .frame(height: 35)
                    })
                    .frame(minWidth: 60)
                    .foregroundStyle(theme.color.onPrimary)
                    .background(theme.color.backgroundGradient)
                    .cornerRadius(100)
                }
            }
            .padding(.vertical, 30)
            
            VStack {
                HStack {
                    Text("Schnellauswahl: ")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(steps, id: \.self) { step in
                                WeightItem(step: step, selected: currentWeight, onTap: { selectedWeight in
                                    withAnimation(.easeInOut) {
                                        currentWeight = selectedWeight
                                    }
                                })
                            }
                        }
                    }
                    
                    
                }.frame(maxHeight: 50)
            }
            
            HStack {
                Button(action: {
                    close()
                }, label: {
                    Text("Abbrechen")
                        .padding(theme.layout.padding)
                })
                .frame(height: 30)
                .frame(minWidth: 100)
                .foregroundStyle(theme.color.onPrimary)
                .background(theme.color.backgroundGradient)
                .cornerRadius(100)
                
                Spacer()
                
                Button(action: {
                    insertWeight() {
                        close()
                    }
                }, label: {
                    Text("Speichern")
                        .padding(theme.layout.padding)
                })
                .withErrorHandling()
                .frame(height: 30)
                .frame(minWidth: 100)
                .foregroundStyle(theme.color.onPrimary)
                .background(theme.color.backgroundGradient)
                .cornerRadius(100)
            }
        }
        .padding(.horizontal, theme.layout.padding)
        .padding(.top, 30)
        .onAppear {
            withAnimation(.easeInOut) {
                self.lastWeight = self.services.weightService.getLastWeight()?.value ?? self.startWeight
                self.currentWeight = self.services.weightService.getLastWeight()?.value ?? self.startWeight
            }
        }
    }
    
    @ViewBuilder func FootLine(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.footnote)
                .foregroundStyle(theme.color.onBackground.opacity(0.5))
        }
    }
    
    func WeightItem(
        step: Double,
        selected: Double,
        onTap: @escaping (Double) -> Void
    ) -> some View {
        ZStack {
            Text(String(format: "%.1f", step))
                .onTapGesture {
                    onTap(step)
                }
        }
        .padding(5)
        .background(
            withAnimation {
                selected == step ? theme.color.primary.opacity(0.15) : theme.color.primary.opacity(0)
            }
        )
        .cornerRadius(20)
        .padding(.horizontal, 5)
    }
    
    @ViewBuilder func DifferenceText(string: String) -> some View {
        Text("(\(string))")
            .font(.footnote)
            .foregroundColor(theme.color.onPrimary.opacity(0.5))
    }
    
    private func insertWeight(close: () -> Void) {
        do {
            if currentWeight <= 30.0 {
                throw WeightError.invalidWeight
            }
            
            guard let user = Auth.auth().currentUser else {
                throw UserError.notLoggedIn
            }
             
            let weightID = UUID()
            let newWeight = Weight(
                id: weightID,
                userId: user.uid,
                weightId: weightID.uuidString,
                value: currentWeight,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
            )
            
            modelContext.insert(newWeight)
            
            close()
        } catch let error {
            errorHandling.handle(error: error)
        }
    }
    
    private func increaseWeight() {
        withAnimation(.easeInOut) {
            currentWeight -= 0.1
        }
    }
    
    private func decreaseWeight() {
        withAnimation(.easeInOut) {
            currentWeight += 0.1
        }
    }
    
    
}
