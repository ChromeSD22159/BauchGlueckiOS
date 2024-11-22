//
//  MedicationViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.11.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

@Observable class MedicationViewModel: ObservableObject {
    let modelContext: ModelContext
    let services: Services
    
    init(modelContext: ModelContext, services: Services) {
        self.modelContext = modelContext
        self.services = services
    }
    
    
    // MARK: STATES
    var medications: [Medication] = []
    
    var userhasMedications: Bool {
        return !medications.isEmpty
    }
    
    var editMedicationIntakeEntries: [IntakeTimeEntry] = []
    
    var medicationViewTab: MedicationViewTab = .intake
    
    let dropDownOptions = [
        DropDownOption(icon: "pencil", displayText: "Bearbeiten"),
        DropDownOption(icon: "trash", displayText: "Löschen"),
        DropDownOption(icon: "trash", displayText: "Delete Intakes DB")
    ]
    
    // Handles DropDown selection actions
    func handleDropDownSelection(item: DropDownOption, medication: Medication) {
        if item.displayText == "Löschen" {
            deleteMedication(medication)
        } else if item.displayText == "Bearbeiten" {
            isEditMedicationSheet = true
        } else if item.displayText == "Delete Intakes DB" {
            medication.intakeTimes.forEach { time in
                time.intakeStatuses.forEach {
                    modelContext.delete($0)
                }
            }
        }
    }
    
    var isEditMedicationSheet: Bool = false
    
    /// Fetch all Medication from user
    func loadMedications() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<Medication> { med in
            med.userId == userID
        }
        
        let sortDescriptor = [
            SortDescriptor(\Medication.name, order: .forward)
        ]
        
        let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sortDescriptor)
         
        do {
            medications = try modelContext.fetch(fetchDescriptor)
        } catch {
            medications = []
        }
    }
    
    /// Delete
    func deleteMedication(_ medication: Medication) {
        MedicationDataService.delete(context: modelContext, medication: medication)
    }
    
    func getMedicationByIndex(_ index: Int) -> Medication {
        return medications[index]
    }
    
    func isTakenToday(intakeTime: IntakeTime) -> Bool {
        let hasEntryForToday: Bool = intakeTime.intakeStatuses.contains { status in
            Calendar.current.isDate(status.date.toDate, inSameDayAs: Date()) && !status.isDeleted
        }

        let hasUntakenForToday: Bool = intakeTime.intakeStatuses.contains { status in
            Calendar.current.isDate(status.date.toDate, inSameDayAs: Date()) && !status.isDeleted && !status.isTaken
        }

        return hasEntryForToday && !hasUntakenForToday
    }
    
    @MainActor
    func takeMedication(forIntakeTime: IntakeTime) {
        MedicationDataService.toggleIntakeStatus(for: forIntakeTime)
        
        services.medicationService.sendUpdatedMedicationToBackend()
    }
    
    func update(medication: Medication, intakeTimeEntries: [IntakeTimeEntry]) throws {
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
            
            await services.weightService.sendUpdatedWeightsToBackend()
            
            isEditMedicationSheet.toggle()
        }
    }
    
    func setMedicationEditIntakeTimeEntries(for medication: Medication) throws {
        do {
            self.editMedicationIntakeEntries = try parseIntakeTimes(intakeTimes: medication.intakeTimes.map { $0.intakeTime })
        } catch {
            throw error
        }
    }
}

enum MedicationViewTab {
    case intake, history
}
