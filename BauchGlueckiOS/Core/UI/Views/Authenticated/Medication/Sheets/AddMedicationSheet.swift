//
//  AddMedicationSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//

import SwiftUI
import FirebaseAuth

struct AddMedicationSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var services: Services
    
    let theme = Theme.shared
    @State private var isSheet = false
   
    @FocusState private var focusedField: FocusedField?
    @State private var name = ""
    @State private var dosis = ""
    @State private var error = ""
    @State var isValid: Bool = false
    @State private var intakeTimeEntries: [IntakeTimeEntry] = []
    
    var body: some View {
        Button(
            action: {
                isSheet = !isSheet
            }, label: {
                Image(systemName: "pills.fill")
                    .foregroundStyle(Theme.shared.onBackground)
            }
        )
        .sheet(isPresented: $isSheet, onDismiss: {}, content: {
            SheetHolder(title: "Medikation anlegen", backgroundImage: true) {
                VStack {
                    TextFieldWithIcon(
                        placeholder: "z.B. Ibuprofen",
                        icon: "pill.fill",
                        title: "Medikament",
                        input: $name,
                        type: .text,
                        focusedField: $focusedField,
                        fieldType: .name,
                        onEditingChanged: { newValue in
                            name = newValue
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
                        input: $dosis,
                        type: .text,
                        focusedField: $focusedField,
                        fieldType: .dosis,
                        onEditingChanged: { newValue in
                            dosis = newValue
                        }
                    )
                    .submitLabel(.done)
                    FootLine(text: "Dosis des Medikaments")
                }
                .padding(.horizontal, 10)
                
                ForEach(intakeTimeEntries.indices, id: \.self) { index in
                    
                    HStack {
                         
                        TimerPicker(hour: $intakeTimeEntries[index].hour, minute: $intakeTimeEntries[index].minute)
                         
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
                
                Button(action: addIntakeTimeEntry) {
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
            .onSubmit {
                switch focusedField {
                    case .name: focusedField = .dosis
                    case .dosis: print( )
                    default: break
                }
           }
        })
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
                onEditingChanged: {
                    insert()
                    services.weightService.sendUpdatedWeightsToBackend()
                }
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
    
    private func insert() {
        Task {
            
            do {
                @State var isValid: Bool = false
                
                if name.count <= 3 {
                    throw ValidationError.invalidName
                }
                
                if dosis.isEmpty {
                    throw ValidationError.invalidDosis
                }
                
                guard let user = Auth.auth().currentUser else {
                    throw ValidationError.userNotFound
                }
                
                let medicationID = UUID()
                let newMedication = Medication(
                    id: medicationID,
                    medicationId: medicationID.uuidString,
                    userId: user.uid,
                    name: name,
                    dosage: dosis,
                    isDeleted: false,
                    updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds
                )
                
                modelContext.insert(newMedication)
                
                for intakeTimeEntry in intakeTimeEntries {
                    let intakeTimeId = UUID()
                    let intakeTime = IntakeTime(
                        id: intakeTimeId,
                        intakeTimeId: intakeTimeId.uuidString,
                        intakeTime: "\(intakeTimeEntry.hour):\(intakeTimeEntry.minute)",
                        medicationId: medicationID.uuidString,
                        isDeleted: false,
                        updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                        medication: newMedication
                    )

                    newMedication.intakeTimes.append(intakeTime)
                    
                    NotificationService.shared.checkAndUpdateRecurringNotification(forMedication: newMedication, forIntakeTime: intakeTime)
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
        
        // Minuten auf den nächsten 5er-Schritt runden
        let roundedMinute = (minute / 5) * 5
        
        let newEntry = IntakeTimeEntry(id: UUID(), hour: hour, minute: roundedMinute)
        intakeTimeEntries.append(newEntry)
    }
    
    private func deleteTimeEntry(_ entry: IntakeTimeEntry) {
        intakeTimeEntries.removeAll { $0.id == entry.id }
    }
    
    enum ValidationError: String, Error {
        case invalidName = "Der Name muss mindestens 3 Buchstaben beinhalten."
        case invalidDosis = "Die Dosis sollte nicht leer sein."
        case userNotFound = "Ein Fehler mit deinem Profil ist aufgetreten. Kontaktiere den Entwickler."
        case medikationExist = "Ein Medikament mit dem Namen existiert bereits."
    }
}

#Preview {
    @Previewable @State var hour: Int = Calendar.current.component(.hour, from: Date())
    @Previewable @State var minute: Int = Calendar.current.component(.minute, from: Date())
    
    TimerPicker(hour: $hour, minute: $minute)
}

struct TimerPicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    var body: some View {
        HStack {
            IntegerPicker(value: $hour, type: .hour)
            
            Text(":")
            
            IntegerPicker(value: $minute, type: .minute)
        }
    }
}

struct IntegerPicker: View {
    var range: [Int]
     
    @Binding var value: Int
    
    init(value: Binding<Int>, type: IntegerPicker.type = .hour) {
        self.range = switch type {
            case .hour: Array(0..<24)
            case .minute: stride(from: 0, to: 60, by: 5).map { $0 }
        }
        
        self._value = value
    }
    
    var body: some View {
        Picker("", selection: $value) {
            ForEach(range, id: \.self) { integer in
                Text(integer.formattedWithLeadingZero())
            }
        }
        .accentColor(Theme.shared.onBackground)
        .pickerStyle(.menu)
    }
    
    enum type {
        case hour, minute
    }
}

extension Int {
    /// Gibt die Zahl als String mit führender Null zurück, falls sie einstellig ist.
    func formattedWithLeadingZero() -> String {
        return String(format: "%02d", self)
    }
}
