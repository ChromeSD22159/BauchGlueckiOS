//
//  AddTimerSheetContent.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct AddTimerSheet: View {
    @State private var isSheet = false
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
            let config = AppConfig.shared.timerConfig
            let _ = print(config.stepsInSeconds)
            AddTimerSheetContent(
                durationRange: config.durationRange,
                stepsEach: config.stepsEach,
                steps: config.stepsInSeconds
            ) .presentationDragIndicator(.visible)
        })
    }
}

struct AddTimerSheetContent: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    private let theme: Theme = Theme.shared
    
    // FormStates
    @FocusState private var focusedField: FocusedField?
    @State private var name: String = ""
    @State private var time: Int = 0
    @State private var error: String = ""
    
    var durationRange: ClosedRange<Int>
    var stepsEach: Int
    var steps: [Int]
    
    var body: some View {
        AppBackground(color: theme.background) {
            theme.bubbleBackground {
                VStack(spacing: 16) {
                    
                    VStack {
                        Image(.magen)
                            .resizable()
                            .frame(width: 150, height: 150)
                        
                        Text("Erstellen deinen Timer")
                            .font(theme.headlineText)
                            .foregroundStyle(theme.primary)
                    }.padding(.bottom, 30)
                    
                    VStack {
                        TextFieldWithIcon(
                            placeholder: "Timername",
                            icon: "gauge.with.dots.needle.bottom.100percent",
                            title: "Name",
                            input: $name,
                            type: .text,
                            focusedField: $focusedField,
                            fieldType: .name,
                            onEditingChanged: { newValue in
                                name = newValue
                            }
                        )
                        .submitLabel(.done)
                        FootLine(text: "Dient zur besseren Differenzierung des Timers")
                    }
                    .padding(.horizontal, 10)
                    
                    
                    VStack {
                        Stepper(
                            value: $time,
                            in: durationRange,
                            step: stepsEach,
                            label: {
                                Text(String(format: NSLocalizedString("Laufzeit: %d Minuten", comment: ""), time / 60))
                            }
                        )
                        
                        
                        HStack {
                            Text("Schnellauswahl: ")
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(steps, id: \.self) { step in
                                        TimerItem(step: step, selected: time, onTap: { selectedStep in
                                            time = selectedStep
                                        })
                                    }
                                }
                            }
                        }.frame(maxHeight: 50)
                    }.padding(.horizontal, 20)
                    
                    
                    HStack {
                        IconTextButton(
                            text: "Abbrechen",
                            onEditingChanged: { dismiss() }
                        )
                        
                        IconTextButton(
                            text: "Speichern",
                            onEditingChanged: { insertTimer() }
                        )
                    }
                    HStack {
                        Text(error)
                            .foregroundStyle(Color.red)
                            .opacity(error.isEmpty ? 0 : 1)
                            .font(.footnote)
                    }
                }
            }
        }
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
    
    private func insertTimer() {
        Task {
            
            do {
                @State var isValid: Bool = false
                
                if name.count <= 3 {
                    throw ValidationError.invalidName
                }
                
                if time <= 0 {
                    throw ValidationError.invalidDuration
                }
                
                guard let user = Auth.auth().currentUser else {
                    throw ValidationError.userNotFound
                }
                
                let date = Date()
                let newTimer = CountdownTimer(
                    timerID: UUID().uuidString,
                    userID: user.uid,
                    name: name,
                    duration: Int64(time * 60),
                    timerState: TimerState.notRunning.rawValue,
                    showActivity: true,
                    isDeleted: false,
                    updatedAtOnDevice: date.timeIntervalSince1970Milliseconds,
                    createdAt: date.ISO8601Format(),
                    updatedAt: date.ISO8601Format()
                )
                
                modelContext.insert(newTimer)
            } catch let error {
                printError(error.localizedDescription)
            }
            
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
        case invalidName = "Der Name muss mindestens 3 Buchstaben beinhalten."
        case invalidDuration = "Die Laufzeit kann nicht 0 sein."
        case userNotFound = "Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
    }
}

func TimerItem(
    step: Int,
    selected: Int,
    onTap: @escaping (Int) -> Void,
    theme: Theme = Theme.shared
) -> some View {
    ZStack {
        Text("\(step / 60)")
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

#Preview(body: {
    AddTimerSheetContent(
        durationRange: 0...(60 * 90),
        stepsEach: 5,
        steps: [5,10,15,20,25,30,35,40,45,50,55,60]
    )
    .modelContainer(localDataScource)
})
