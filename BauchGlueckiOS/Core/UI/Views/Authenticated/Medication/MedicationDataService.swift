//
//  MedicationDataService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 01.11.24.
//
import SwiftData
import FirebaseAuth
import SwiftUI
import Alamofire

struct MedicationDataService {
    static func userHasMedication(context: ModelContext) -> [Medication] {
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        var descriptor = FetchDescriptor<Medication>(
            predicate: #Predicate<Medication> { $0.userId == userID }
        )
        
        descriptor.fetchLimit = 1
        
        do {
            let results = try context.fetch(descriptor)
            return results
        } catch {
            print("Unable to fetch Medication items")
            return [Medication]()
        }
    }
    
    static func findNextMedicationIntake(medications: [Medication]) -> NextMedicationForToday? {
        var nextEntries: [NextMedicationForToday] = []

        medications.forEach { medication in
            medication.intakeTimes.forEach { intakeTime in
                guard let timeOfIntake = intakeTime.intakeTime.toDate else {
                    return
                }

                // Alle Status für heute filtern
                let status = intakeTime.intakeStatuses.filter { status in
                    Calendar.current.isDate(status.date.toDate, inSameDayAs: Date())
                }

                // Intake-Zeit ist relevant, wenn kein Status vorhanden ist oder isTaken == false
                if status.isEmpty || status.contains(where: { !$0.isTaken }) {
                    let nextMedication = NextMedicationForToday(medication: medication, intakeTime: timeOfIntake)
                    nextEntries.append(nextMedication)
                }
            }
        }

        // Alle offenen Einnahmezeiten nach der Zeit sortieren
        nextEntries.sort { $0.intakeTime < $1.intakeTime }

        // Setze den nächsten Eintrag, falls vorhanden
        if let nextIntake = nextEntries.first {
            return nextIntake
        } else {
            return nil
        }
    }
    
    static func delete(context: ModelContext, medication: Medication) {
        context.delete(medication)
    }
    
    static func toggleIntakeStatus(@Bindable for intakeTime: IntakeTime) {
        let updateTimeStamp = Date().timeIntervalSince1970Milliseconds
        
        intakeTime.medication?.updatedAtOnDevice = updateTimeStamp
        intakeTime.updatedAtOnDevice = updateTimeStamp
        
        if let index = intakeTime.intakeStatuses.firstIndex(where: {
            Calendar.current.isDate($0.date.toDate, inSameDayAs: Date())
        }) {
            // Update existing intake status
            print("update")
            let state = intakeTime.intakeStatuses[index].isTaken
            intakeTime.intakeStatuses[index].isTaken = !state
            intakeTime.intakeStatuses[index].updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
        } else {
            // Create new intake status for today
            print("create")
            let newStatus = IntakeStatus(
                intakeStatusId: UUID().uuidString,
                intakeTimeId: intakeTime.intakeTimeId,
                date: Date().timeIntervalSince1970Milliseconds,
                isTaken: true,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                intakeTime: intakeTime
            )
            intakeTime.intakeStatuses.append(newStatus)
        }
    }
}


