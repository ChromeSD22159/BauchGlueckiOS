//
//  NextMedicationCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

#Preview {
    NextMedicationCard()
        .modelContainer(previewDataScource)
}

struct NextMedicationCard: View {
    @Query() var medications: [Medication]
    
    var nextMedicationCard: Medication? {
        getNextMedicationCard(medications: medications)
    }
    
    var body: some View {
        VStack {
            
            if let nextMedicationCard = nextMedicationCard {
                Text("Next: \(nextMedicationCard.name) \(nextMedicationCard.intakeTimes.count)")
                ForEach(nextMedicationCard.intakeTimes) { time in
                    Text("Intakes: \(time.intakeStatuses.count)")
                }
            }
            
            
            Text("\n\n")
            
            Text("MEDICATION: \(medications.count)")
            
            ForEach(medications) { med in
                Text("Intakes: \(med.intakeTimes.count)")
                
                ForEach(med.intakeTimes) { time in
                    Text("Times: \(time.intakeStatuses.count)")
                }
            }
            
            NoMedication()
        }
    }
    
    func getNextMedicationCard(medications: [Medication]) -> Medication? {
        let currentDate = Date()
        let calendar = Calendar.current

        return medications
            .flatMap { (medication: Medication) -> [IntakeTime] in
                medication.intakeTimes.compactMap { (intakeTime: IntakeTime) -> IntakeTime? in
                    guard !intakeTime.isDeleted else { return nil }
                    let todayStatuses = intakeTime.intakeStatuses.filter { (status: IntakeStatus) -> Bool in
                        let statusDate = Date(timeIntervalSince1970: TimeInterval(status.date) / 1000)
                        return calendar.isDate(statusDate, inSameDayAs: currentDate) && !status.isDeleted
                    }
                    return todayStatuses.isEmpty ? intakeTime : nil
                }
            }
            .sorted { $0.intakeTime < $1.intakeTime }
            .first?.medication
    }

}

struct NoMedication: View {
    let theme: Theme = Theme.shared
    var body: some View {
        VStack {
            Text("Medikamente für \(formattedDate(Date()))")
                .font(theme.headlineTextSmall)
            
            Text("Du hast heute keine Medikamente zum einnehmen.")
                .font(.footnote)
        }
        .padding(theme.padding)
        .foregroundStyle(theme.onBackground)
        .sectionShadow(margin: theme.padding)
    }
}
