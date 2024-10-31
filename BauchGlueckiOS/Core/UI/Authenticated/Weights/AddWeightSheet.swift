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

    @State private var isSheet = false
    
    var startWeight: Double
    
    var body: some View {
        Button(
            action: {
                isSheet.toggle()
            }, label: {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent.badge.plus")
                    .foregroundStyle(Theme.shared.onBackground)
            }
        )
        .sheet(isPresented:$isSheet) {
            SheetHolder(title: "Gewicht eintragen") {
                let config = AppConfig.shared.weightConfig
                AddWeightSheetContent(
                    durationRange: config.weightRange,
                    stepsEach: config.stepsEach,
                    steps: config.stepsInSeconds,
                    startWeight: startWeight
                ) {
                    isSheet.toggle()
                }
            }
        }
    }
}

struct AddWeightSheetContent: View {
    @Environment(\.modelContext) var modelContext: ModelContext
 
    private let theme: Theme = Theme.shared
    @Query() var weights: [Weight]
    
    // FormStates
    @State private var currentWeight: Double = 90.0
    @State var lastWeight: Double = 0.0
    @State private var error: String = ""

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
        
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<Weight> { weight in
            weight.userID == userID
        }
        
        self._weights = Query(
            filter: predicate,
            sort: \Weight.weighed
        )
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
                                .foregroundColor(theme.onPrimary)
                            
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
                            .padding(theme.padding)
                            .frame(height: 35)
                    })
                    .frame(minWidth: 60)
                    .foregroundStyle(theme.onPrimary)
                    .background(theme.backgroundGradient)
                    .cornerRadius(100)
                    
                    Spacer()
                    
                    Button(action: {
                        decreaseWeight()
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
                        .padding(theme.padding)
                })
                .frame(height: 30)
                .frame(minWidth: 100)
                .foregroundStyle(theme.onPrimary)
                .background(theme.backgroundGradient)
                .cornerRadius(100)
                
                Spacer()
                
                Button(action: {
                    insertWeight() {
                        close()
                    }
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
        .onAppear {
            let sortedWeights = self.weights.sorted(by: { first, second in
                guard let firstDate = ISO8601DateFormatter().date(from: first.weighed), let secondDate = ISO8601DateFormatter().date(from: second.weighed) else { return false }
                return firstDate > secondDate
            })
            
            withAnimation(.easeInOut) {
                self.lastWeight = sortedWeights.first?.value ?? self.startWeight
                self.currentWeight = sortedWeights.first?.value ?? self.startWeight
            }
        }
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
    
    @ViewBuilder func DifferenceText(string: String) -> some View {
        Text("(\(string))")
            .font(.footnote)
            .foregroundColor(theme.onPrimary.opacity(0.5))
    }
    
    private func insertWeight(close: () -> Void) {
        do {
            if currentWeight <= 30.0 {
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
                value: currentWeight,
                isDeleted: false,
                weighed: date.ISO8601Format(),
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
            )
            
            modelContext.insert(newWeight)
            
            close()
        } catch let error {
            printError(error.localizedDescription)
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
    
    enum ValidationError: String, Error {
        case invalidWeight = "Der Name muss mindestens 3 Buchstaben beinhalten."
        case userNotFound = "Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
    }
}
