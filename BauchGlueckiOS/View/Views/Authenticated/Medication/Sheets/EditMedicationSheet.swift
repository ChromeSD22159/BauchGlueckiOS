//
//  EditMedicationSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData
 
// TODO: TIMES NOT CHANGEABLE
struct EditMedicationSheet: View {
    @Bindable var medication: Medication
    
    @Environment(\.theme) private var theme
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    
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
             
            VStack {
                ForEach(medicationViewModel.editMedicationIntakeEntries.indices, id: \.self) { index in
                    HStack {
                        HourMinutePicker(hour: $medicationViewModel.editMedicationIntakeEntries[index].hour, minute: $medicationViewModel.editMedicationIntakeEntries[index].minute)
                         
                        ZStack(alignment: .topTrailing) {
                            Button(action: { deleteTimeEntry(medicationViewModel.editMedicationIntakeEntries[index]) }) {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                                    .foregroundStyle(theme.color.onBackground)
                                    .padding(5)
                            }
                            .background(Material.ultraThin)
                            .cornerRadius(100)
                        }
                    }
                    .padding(theme.layout.padding)
                    .background(theme.color.surface)
                    .cornerRadius(theme.layout.radius)
                }
            }
            
            Button(action: {
                if intakeTimeEntries.count < 4 {
                    addIntakeTimeEntry()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .foregroundStyle(theme.color.primary)
                    
                    Text("Hinzufügen")
                        .foregroundStyle(theme.color.onBackground)
                    
                    Spacer()
                }
                .padding(theme.layout.padding)
                .background(theme.color.surface)
                .cornerRadius(theme.layout.radius)
                .shadow(radius: 5)
                .padding(.horizontal, theme.layout.padding)
            }
            
            Controll() 
            
            Spacer()
        }
        .withErrorHandling()
        .onAppear {
            loadIntakeTimeEntries()
        }
        .onSubmit {
            switch focusedField {
                case .name: focusedField = .dosis
                case .dosis: focusedField = nil
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
            FootLineText(text, color: theme.color.onBackground.opacity(0.5)) 
        }
    }
    
    @ViewBuilder func Controll() -> some View {
        HStack {
            IconTextButton(
                text: "Abbrechen",
                onEditingChanged: { medicationViewModel.isEditMedicationSheet.toggle() }
            )
            
            Spacer()
            
            TryButton(text: "Speichern") {
                try medicationViewModel.update(medication: medication, intakeTimeEntries: intakeTimeEntries)
            }
            .buttonStyle(CapsuleButtonStyle())
        }
        .padding(.horizontal)
    }
    
    private func addIntakeTimeEntry() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())

        let clampedHour = max(0, min(hour, 23))
        let clampedMinute = max(0, min(minute, 59))

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
    
    private func loadIntakeTimeEntries() {
        do {
            try medicationViewModel.setMedicationEditIntakeTimeEntries(for: medication)
        } catch {
            errorHandling.handle(error: error)
        }
    }
}

func parseIntakeTimes(intakeTimes: [String]) throws -> [IntakeTimeEntry] {
    var entries: [IntakeTimeEntry] = []

    for intakeTime in intakeTimes {
        let values = intakeTime.split(separator: ":")
        
        // Überprüfen, ob das Format korrekt ist
        guard values.count == 2 else {
            throw IntakeTimeError.invalidFormat(intakeTime)
        }
        
        // Konvertierung von Stunden und Minuten
        guard let hour = Int(values[0]), let minute = Int(values[1]) else {
            throw IntakeTimeError.conversionFailed(intakeTime)
        }
        
        // Erstellen des IntakeTimeEntry
        let entry = IntakeTimeEntry(id: UUID(), hour: hour, minute: minute)
        entries.append(entry)
    }
    
    return entries
     
    enum IntakeTimeError: Error {
        case invalidFormat(String)  // IntakeTime als String
        case conversionFailed(String)
        
        var description: String {
            switch self {
                case .invalidFormat(let intakeTime): return "Ungültiges intakeTime-Format: \(intakeTime)"
                case .conversionFailed(let intakeTime): return "Konvertierungsfehler für intakeTime: \(intakeTime)"
            }
        }
    }
}
