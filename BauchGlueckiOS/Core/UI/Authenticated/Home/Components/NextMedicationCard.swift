//
//  NextMedicationCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

#Preview {
    NextMedication()
        .modelContainer(previewDataScource)
}

struct NextMedication: View {
    let theme: Theme = Theme.shared
    
    @Query() var medications: [Medication]
    
    var body: some View {
        VStack {
            if medications.count > 0 {
                NextMedicationCard()
            } else {
                NoMedication()
            }
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

struct NextMedicationCard: View {
    let theme: Theme = Theme.shared
    @Query() var medications: [Medication]
    @State var nextMedication: NextMedicationForToday? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("Medikamente für \(formattedDate(Date()))")
                    .font(theme.headlineTextSmall)
                
                
                
                if let next = nextMedication {
                    VStack {
                        Text("Nachstes Medikament für Heute:")
                            .font(.footnote)
                        
                        Text("\(next.medication.name) um \(DateRepository.formatTimeToHHmm(date: next.intakeTime)) Uhr")
                            .font(.footnote)
                    }
                } else {
                    VStack {
                        Text("Du hast bereits alles Eingenommen!")
                            .font(.footnote)
                    }
                }
            }
            
            VStack(spacing: 10) {
                ForEach(medications) { medication in
                    HStack {
                        Text(medication.name)
                            .font(.footnote)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        let sortedIntakeTimes = medication.intakeTimes.sorted(by: {
                            $0.intakeTime.toDate! < $1.intakeTime.toDate!
                        })
                        
                        let formattedIntakeTimes = sortedIntakeTimes.map { "\($0.intakeTime)" }.joined(separator: ", ") + " Uhr"
                        
                        Text(formattedIntakeTimes)
                            .font(.footnote)
                    }
                }
            }
        }
        .padding(theme.padding)
        .foregroundStyle(theme.onBackground)
        .sectionShadow(margin: theme.padding)
        .onAppear {
            findNextMedicationIntake()
        }
        .onChange(of: medications) {
            findNextMedicationIntake()
        }
    }
    
    private func findNextMedicationIntake() {
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
            self.nextMedication = nextIntake
        } else {
            self.nextMedication = nil
        }
    }
}
