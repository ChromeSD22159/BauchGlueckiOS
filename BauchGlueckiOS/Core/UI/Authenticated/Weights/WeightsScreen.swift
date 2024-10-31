//
//  Weights.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct WeightsScreen: View {
    let theme: Theme = Theme.shared
    var startWeight: Double
    
    @State private var currentWeight: Double = 0.0
    
    var totalWeightLost: Double {
        self.startWeight - self.currentWeight
    }
    
    var body: some View {
        ScreenHolder() {
            VStack(spacing: theme.padding) {
                // Totaler gewichts Verlust: 46.00 KG
                
                Text(String(format: "Totaler Gewichtsverlust: %.1fkg", totalWeightLost))
                
                // Differenz:
            }.padding(.horizontal, theme.padding)
        }
    }
    
    private func loadLastWeight() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        let weight = Query(filter: #Predicate<Weight> { weight in
            weight.userID == userID
        }, sort: \.weighed)
        
        let lastWeight = weight.wrappedValue.sorted(by: { first, second in
            guard let firstDate = ISO8601DateFormatter().date(from: first.weighed), let secondDate = ISO8601DateFormatter().date(from: second.weighed) else { return false }
            return firstDate > secondDate
        })
        
        self.currentWeight = lastWeight.first?.value ?? self.startWeight
    }
}

struct AddWeightSheet: View {

    @State private var isSheet = false
    
    var startWeight: Double
    
    var body: some View {
        Button(
            action: {
                isSheet = !isSheet
            }, label: {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent.badge.plus")
                    .foregroundStyle(Theme.shared.onBackground)
            }
        )
        .sheet(isPresented:$isSheet, onDismiss: {}, content: {
            let config = AppConfig.shared.weightConfig
            let _ = print(config.stepsInSeconds)
            
            SheetHolder(title: "Gewicht eintragen") {
                AddWeightSheetContent(
                    durationRange: config.weightRange,
                    stepsEach: config.stepsEach,
                    steps: config.stepsInSeconds,
                    startWeight: startWeight
                )
            }
        })
    }
}

#Preview {
    let config = AppConfig.shared.weightConfig
    AddWeightSheetContent(durationRange: config.weightRange, stepsEach: config.stepsEach, steps: config.stepsInSeconds, startWeight: 90.0)
        .modelContainer(previewDataScource)
}

struct AddWeightSheetContent: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @Environment(\.dismiss) var dismiss
    private let theme: Theme = Theme.shared
    
    // FormStates
    @FocusState private var focusedField: FocusedField?
    @State private var weight: Double = 90.0
    @State private var error: String = ""
    
    var startWeight: Double
    var durationRange: ClosedRange<Double>
    var stepsEach: Double
    var steps: [Double]
    
    init(
        durationRange: ClosedRange<Double>,
        stepsEach: Double,
        steps: [Double],
        startWeight: Double
    ) {
        self.durationRange = durationRange
        self.stepsEach = stepsEach
        self.steps = steps
        self.weight = startWeight
        self.startWeight = startWeight
        loadLastWeight()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            VStack {
                Image(.magen)
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Text("Neues Gewicht hinzufügen")
                    .font(theme.headlineText)
                    .foregroundStyle(theme.primary)
            }
            
            ZStack(alignment: .bottom) {
                VStack {
                    let weightDifferenceSigned = abs(weight - startWeight)
                    let weightDifferenceUnsigned = weight - startWeight
                                    
                    Gauge(value: weightDifferenceSigned, in: 0...abs(startWeight)) {
                        Image(systemName: "gauge.medium")
                            .font(.system(size: 50.0))
                    } currentValueLabel: {
                        if weightDifferenceUnsigned == 0.0 {
                            Text("\(weightDifferenceSigned.formatted(.number))")
                        } else if weightDifferenceUnsigned > 0.0 {
                            Text("\("+")\(weightDifferenceSigned.formatted(.number))")
                        } else {
                            Text("\("-")\(weightDifferenceSigned.formatted(.number))")
                        }
                    }
                    .gaugeStyle(WeightOmeterGaugeStyle())
                    Spacer()
                }
                
                HStack {
                    Button(action: {
                        decreaseWeight()
                    }, label: {
                        Image(systemName: "minus")
                            .font(.headline)
                            .padding(theme.padding)
                            .frame(height: 35)
                    })
                    .frame(minWidth: 60)
                    .foregroundStyle(theme.onPrimary)
                    .background(theme.backgroundGradient)
                    .cornerRadius(100)
                    
                    Spacer()
                    
                    Button(action: {
                        increaseWeight()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .padding(theme.padding)
                            .frame(height: 35)
                    })
                    .frame(minWidth: 60)
                    .foregroundStyle(theme.onPrimary)
                    .background(theme.backgroundGradient)
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
                                WeightItem(step: step, selected: weight, onTap: { selectedWeight in
                                    withAnimation(.easeInOut) {
                                        weight = selectedWeight
                                    }
                                })
                            }
                        }
                    }
                }.frame(maxHeight: 50)
            }
            
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Abbrechen")
                        .padding(theme.padding)
                })
                .frame(height: 30)
                .frame(minWidth: 100)
                .foregroundStyle(theme.onPrimary)
                .background(theme.backgroundGradient)
                .cornerRadius(100)
                
                Spacer()
                
                Button(action: {
                    insertWeight()
                }, label: {
                    Text("Speichern")
                        .padding(theme.padding)
                })
                .frame(height: 30)
                .frame(minWidth: 100)
                .foregroundStyle(theme.onPrimary)
                .background(theme.backgroundGradient)
                .cornerRadius(100)
            }
            
            HStack {
                Text(error)
                    .foregroundStyle(Color.red)
                    .opacity(error.isEmpty ? 0 : 1)
                    .font(.footnote)
            }
        }
        .padding(.horizontal, theme.padding)
        .padding(.top, 30)
    }
    
    enum FocusedField {
        case name
    }
    
    @ViewBuilder func FootLine(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.footnote)
                .foregroundStyle(Theme.shared.onBackground.opacity(0.5))
        }
    }
    
    func WeightItem(
        step: Double,
        selected: Double,
        onTap: @escaping (Double) -> Void,
        theme: Theme = Theme.shared
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
                selected == step ? theme.primary.opacity(0.15) : theme.primary.opacity(0)
            }
        )
        .cornerRadius(20)
        .padding(.horizontal, 5)
    }
    
    private func insertWeight() {
        Task {
            
            do {
                if weight <= 30.0 {
                    throw ValidationError.invalidWeight
                }
                
                guard let user = Auth.auth().currentUser else {
                    throw ValidationError.userNotFound
                }
                
                let date = Date()
                let weightID = UUID()
                let newWeight = Weight(
                    id: weightID,
                    userID: user.uid,
                    weightId: weightID.uuidString,
                    value: weight,
                    isDeleted: false,
                    weighed: date.ISO8601Format(),
                    updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
                )
                
                modelContext.insert(newWeight)
                
                dismiss()
            } catch let error {
                printError(error.localizedDescription)
            }
            
        }
    }
    
    private func increaseWeight() {
        withAnimation(.easeInOut) {
            weight -= 0.1
        }
    }
    
    private func decreaseWeight() {
        withAnimation(.easeInOut) {
            weight += 0.1
        }
    }
    
    private func printError(_ text: String) {
        Task {
            try await awaitAction(
                seconds: 2,
                startAction: {
                    error = text
                },
                delayedAction: {
                    error = ""
                }
            )
        }
    }
    
    private func loadLastWeight() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        let weight = Query(filter: #Predicate<Weight> { weight in
            weight.userID == userID
        }, sort: \.weighed)
        
        let lastWeight = weight.wrappedValue.sorted(by: { first, second in
            guard let firstDate = ISO8601DateFormatter().date(from: first.weighed), let secondDate = ISO8601DateFormatter().date(from: second.weighed) else { return false }
            return firstDate > secondDate
        })
        
        withAnimation(.easeInOut) {
            self.weight = lastWeight.first?.value ?? self.startWeight
        }
    }
    
    enum ValidationError: String, Error {
        case invalidWeight = "Der Name muss mindestens 3 Buchstaben beinhalten."
        case userNotFound = "Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
    }
}
