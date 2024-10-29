//
//  EditMedicationSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

struct EditMedicationSheet: View {
    @Bindable var medication: Medication
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    let theme = Theme.shared
   
    @FocusState private var focusedField: FocusedField?
  
    @State private var error = ""
    @State private var intakeTimeEntries: [IntakeTimeEntry] = []
    
    var body: some View {
        SheetHolder(title: "Medikation bearbeiten", backgroundImage: true) {
            VStack {
                TextFieldWithIcon(
                    placeholder: "z.B. Ibuprofen",
                    icon: "pill.fill",
                    title: "Medikament",
                    input: $medication.name,
                    type: .text,
                    focusedField: $focusedField,
                    fieldType: .name,
                    onEditingChanged: { newValue in
                        medication.name = newValue
                    }
                )
                .submitLabel(.next)
                FootLine(text: "Name des Medikaments")
            }
            .padding(.top, 50)
            .padding(.horizontal, 10)
            
            VStack {
                TextFieldWithIcon(
                    placeholder: "z.B. 400mg",
                    icon: "rectangle.and.pencil.and.ellipsis",
                    title: "Dosis",
                    input: $medication.dosage,
                    type: .text,
                    focusedField: $focusedField,
                    fieldType: .dosis,
                    onEditingChanged: { newValue in
                        medication.dosage = newValue
                    }
                )
                .submitLabel(.done)
                FootLine(text: "Dosis des Medikaments")
            }
            .padding(.horizontal, 10)
            
            ForEach(intakeTimeEntries.indices, id: \.self) { index in
                HStack {
                    TextField("Stunde", value: Binding(
                        get: { intakeTimeEntries[index].hour },
                        set: { intakeTimeEntries[index].hour = $0 }
                    ), format: .number)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .frame(width: 30)

                    Text(":")

                    TextField("Minute", value: Binding(
                        get: { intakeTimeEntries[index].minute },
                        set: { intakeTimeEntries[index].minute = $0 }
                    ), format: .number)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .frame(width: 30)

                    ZStack(alignment: .topTrailing) {
                        Button(action: { deleteTimeEntry(intakeTimeEntries[index]) }) {
                            Image(systemName: "xmark")
                                .font(.caption2)
                                .foregroundStyle(theme.onBackground)
                                .padding(5)
                        }
                        .background(Material.ultraThin)
                        .cornerRadius(100)
                    }
                }
                .padding(theme.padding)
                .background(theme.surface)
                .cornerRadius(theme.radius)
            }
            
            Button(action: {
                if intakeTimeEntries.count < 4 {
                    addIntakeTimeEntry()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .foregroundStyle(theme.primary)
                    
                    Text("Hinzufügen")
                        .foregroundStyle(theme.onBackground)
                    
                    Spacer()
                }
                .padding(theme.padding)
                .background(theme.surface)
                .cornerRadius(theme.radius)
                .shadow(radius: 5)
                .padding(.horizontal, theme.padding)
            }
            
            Controll()
            
            ErrorRow()
            
            Spacer()
        }
        .onAppear {
            intakeTimeEntries = medication.intakeTimes.map { intakeTime in
                let components = intakeTime.intakeTime.split(separator: ":").compactMap { Int($0) }
                return IntakeTimeEntry(id: UUID(), hour: components.first ?? 0, minute: components.last ?? 0)
            }
        }
        .onSubmit {
            switch focusedField {
                case .name: focusedField = .dosis
                case .dosis: print()
                default: break
            }
       }
    }
    
    enum FocusedField {
        case name, dosis
    }
    
    @ViewBuilder func FootLine(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.footnote)
                .foregroundStyle(Theme.shared.onBackground.opacity(0.5))
        }
    }
    
    @ViewBuilder func Controll() -> some View {
        HStack {
            IconTextButton(
                text: "Abbrechen",
                onEditingChanged: { dismiss() }
            )
            
            IconTextButton(
                text: "Speichern",
                onEditingChanged: { update() }
            )
        }
    }
    
    @ViewBuilder func ErrorRow() -> some View {
        HStack {
            Text(error)
                .foregroundStyle(Color.red)
                .opacity(error.isEmpty ? 0 : 1)
                .font(.footnote)
        }
    }
    
    private func update() {
        Task {
            do {
                if medication.name.count <= 3 {
                    throw ValidationError.invalidName
                }
                
                if medication.dosage.isEmpty {
                    throw ValidationError.invalidDosis
                }
                
                medication.intakeTimes.removeAll { intakeTime in
                    !intakeTimeEntries.contains { entry in
                        intakeTime.intakeTime == "\(entry.hour):\(entry.minute)"
                    }
                }
                
                for intakeTimeEntry in intakeTimeEntries {
                    let intakeTimeString = "\(intakeTimeEntry.hour):\(intakeTimeEntry.minute)"
                    let exist = medication.intakeTimes.first { intake in
                        intake.intakeTime == intakeTimeString
                    }
                    
                    if exist == nil {
                        let intakeTimeId = UUID()
                        let intakeTime = IntakeTime(
                            id: intakeTimeId,
                            intakeTimeId: intakeTimeId.uuidString,
                            intakeTime: intakeTimeString,
                            medicationId: medication.medicationId,
                            isDeleted: false,
                            updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                            medication: medication
                        )

                        medication.intakeTimes.append(intakeTime)
                    }
                }
                
                dismiss()
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
    
    private func addIntakeTimeEntry() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())

        let clampedHour = max(0, min(hour, 23))
        let clampedMinute = max(0, min(hour, 59))

        let formattedHour = String(clampedHour).padding(toLength: 2, withPad: "0", startingAt: 0)
        let formattedMinute = String(clampedMinute).padding(toLength: 2, withPad: "0", startingAt: 0)

        let formattedHourAsInt = Int(formattedHour) ?? 0
        let formattedMinuteAsInt = Int(formattedMinute) ?? 0
        
        let newEntry = IntakeTimeEntry(id: UUID(), hour: formattedHourAsInt, minute: formattedMinuteAsInt)
        intakeTimeEntries.append(newEntry)
    }
    
    private func deleteTimeEntry(_ entry: IntakeTimeEntry) {
        intakeTimeEntries.removeAll { $0.id == entry.id }
        
        // Reflect deletion in the medication object
        medication.intakeTimes.removeAll { intake in
            intake.intakeTime == "\(entry.hour):\(entry.minute)"
        }
    }
    
    enum ValidationError: String, Error {
        case invalidName = "Der Name muss mindestens 3 Buchstaben beinhalten."
        case invalidDosis = "Die Dosis sollte nicht leer sein."
        case userNotFound = "Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
    }
}
