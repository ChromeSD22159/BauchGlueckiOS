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
    @Environment(\.modelContext) var modelContext
    @Environment(\.theme) private var theme
    @EnvironmentObject var services: Services
    
    @Binding var isPresented: Bool
    var durationRange: ClosedRange<Int>
    var stepsEach: Int
    var steps: [Int]
    
    // FormStates
    @FocusState private var focusedField: FocusedField?
    @State private var error: String = ""

    var body: some View {
        AppBackground(color: theme.color.background) {
            theme.bubbleBackground {
                VStack(spacing: 16) {
                    
                    VStack {
                        Image(.magen)
                            .resizable()
                            .frame(width: 150, height: 150)
                        
                        Text("Erstellen deinen Timer")
                            .font(theme.font.headlineText)
                            .foregroundStyle(theme.color.primary)
                    }.padding(.bottom, 30)
                    
                    
                    VStack {
                        TextFieldWithIcon(
                            placeholder: "Timername",
                            icon: "gauge.with.dots.needle.bottom.100percent",
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
                        )
                        
                        HStack {
                            Text("Schnellauswahl: ")
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(steps, id: \.self) { step in
                                        TimerItem(step: step, selected: timer.duration, onTap: { selectedStep in
                                            timer.duration = selectedStep
                                        })
                                    }
                                }
                            }
                        }.frame(maxHeight: 50)
                        
                    }.padding(.horizontal, 10)
                    
                    
                    HStack {
                        IconTextButton(
                            text: "Abbrechen",
                            onEditingChanged: { isPresented.toggle() }
                        )
                        
                        IconTextButton(
                            text: "Speichern",
                            onEditingChanged: {                                
                                do {
                                    try modelContext.save()
                                    
                                    isPresented.toggle()
                                } catch { }
                            }
                        )
                    }
                    HStack {
                        FootLineText(error, color: .red)
                            .opacity(error.isEmpty ? 0 : 1) 
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
            FootLineText(text, color: theme.color.onBackground.opacity(0.5)) 
        }
    }
    
    private func printError(_ text: String) {
        Task {
            try await DelayUtil.awaitAction(
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
