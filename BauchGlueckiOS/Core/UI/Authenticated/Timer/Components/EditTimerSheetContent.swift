//
//  EditTimerSheetContent.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

import SwiftUI
import SwiftData

struct EditTimerSheetContent: View {
    @Bindable var timer: CountdownTimer
    @Environment(\.dismiss) var dismiss
    private let theme: Theme = Theme.shared
    
    var durationRange: ClosedRange<Int>
    var stepsEach: Int
    
    // FormStates
    @FocusState private var focusedField: FocusedField?
    @State private var error: String = ""
    
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
                            icon: "lock.fill",
                            title: "Name",
                            input: $timer.name,
                            type: .text,
                            focusedField: $focusedField,
                            fieldType: .name,
                            onEditingChanged: { newValue in
                                timer.name = newValue
                            }
                        )
                        .submitLabel(.done)
                        FootLine(text: "Dient zur besseren Differenzierung des Timers")
                    }
                    .padding(.horizontal, 10)
                    
                    
                    VStack {
                        Stepper(
                            value: $timer.duration,
                            in: durationRange,
                            step: stepsEach,
                            label: {
                                Text(String(format: NSLocalizedString("Laufzeit: %d Minuten", comment: ""), timer.duration / 60))
                            }
                        ).padding(.horizontal, 10)
                        FootLine(text: "Laufzeit in Minuten.")
                    }.padding(.horizontal, 10)
                    
                    
                    HStack {
                        IconTextButton(
                            text: "Abbrechen",
                            onEditingChanged: { dismiss() }
                        )
                        
                        IconTextButton(
                            text: "Speichern",
                            onEditingChanged: { dismiss() }
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
}
