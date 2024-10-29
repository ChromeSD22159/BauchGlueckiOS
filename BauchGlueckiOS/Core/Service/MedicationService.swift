//
//  MedicationService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftData
import FirebaseAuth

@MainActor
class MedicationService {
    private var context: ModelContext
    private var table: Entitiy
    
    init(context: ModelContext) {
        self.context = context
        self.table = .MEDICATION
    }
    
    func insertMedication(medication: Medication) {
        context.insert(medication)
    }
    
    func getMedicationsWithTodaysIntakeTimes() -> [Medication] {
        guard let userID = Auth.auth().currentUser?.uid else { return [] }

        // Start und Endzeit für das heutige Datum
        let startOfDay = DateService.startToday.timeIntervalSince1970Milliseconds
        let endOfDay = DateService.endOfDAy.timeIntervalSince1970Milliseconds

        // Medikament-Prädikat, um Benutzer-ID zu überprüfen
        let medicationPredicate = #Predicate { (medication: Medication) in
            medication.userId == userID
        }

        // Einnahmestatus-Prädikat für heutige Statusfilterung
        let query = FetchDescriptor<Medication>(
            predicate: medicationPredicate
        )

        do {
            let medications = try context.fetch(query)
            return medications.filter { medication in
                medication.intakeTimes.contains { intakeTime in
                    intakeTime.intakeStatuses.contains { intakeStatus in
                        intakeStatus.date >= startOfDay &&
                        intakeStatus.date < endOfDay
                    }
                }
            }
        } catch {
            print("Error fetching medications: \(error)")
            return []
        }
    }
}
