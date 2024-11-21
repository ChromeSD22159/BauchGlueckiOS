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
    @Binding var isPresented: Bool
    
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext 
    @EnvironmentObject var services: Services
   
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
                        set: { intakeTimeEntries[index].hour = $0 > 23 ? 23 : $0 }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Fertig") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .frame(width: 30)

                    Text(":")

                    TextField("Minute", value: Binding(
                        get: { intakeTimeEntries[index].minute },
                        set: { intakeTimeEntries[index].minute = $0 > 59 ? 59 : $0 }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Fertig") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .frame(width: 30)

                    ZStack(alignment: .topTrailing) {
                        Button(action: { deleteTimeEntry(intakeTimeEntries[index]) }) {
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
        .onTapGesture { focusedField = closeKeyboard(focusedField: focusedField) }
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
                .foregroundStyle(theme.color.onBackground.opacity(0.5))
        }
    }
    
    @ViewBuilder func Controll() -> some View {
        HStack {
            IconTextButton(
                text: "Abbrechen",
                onEditingChanged: { isPresented.toggle() }
            )
            
            TryButton(text: "Speichern") {
                try update()
                services.weightService.sendUpdatedWeightsToBackend()
            }
            .withErrorHandling()
            .buttonStyle(CapsuleButtonStyle())
        }
    }
    
    private func update() throws {
        guard medication.name.count > 3 else { throw MedicationError.invalidName }
        
        guard !medication.dosage.isEmpty else { throw MedicationError.invalidDosis }
        
        Task {
            medication.intakeTimes.removeAll { intakeTime in
                // remove Notification
                NotificationService.shared.removeRecurringNotification(forIntakeTime: intakeTime)
                
                return !intakeTimeEntries.contains { entry in
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
      
                    NotificationService.shared.checkAndUpdateRecurringNotification(forMedication: medication, forIntakeTime: intakeTime)
                }
            }
            
            isPresented.toggle()
        }
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
    
    private func closeKeyboard(focusedField: FocusedField?) -> FocusedField? {
        if focusedField != nil {
            return nil
        }
        
        return focusedField
    }
}
