//
//  NextMedicationCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

#Preview {
    NextMedication()
        .modelContainer(previewDataScource)
}

struct NextMedication: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext
    @State private var medications = [Medication]()
    
    var body: some View {
        VStack {
            if medications.count > 0 {
                NextMedicationCard()
            } else {
                NoMedication()
            }
        }
        .onAppear {
            medications = MedicationDataService.userHasMedication(context: modelContext)
        }
    }
}

struct NextMedicationCard: View {
    @Environment(\.theme) private var theme
    @Query() var medications: [Medication]
    @State var nextMedication: NextMedicationForToday? = nil
    
    init() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        _medications = Query(
            filter: #Predicate<Medication> { med in
                med.userId == userID
            }
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                HeadLineText("Medikamente für \( DateFormatteUtil.formattedFullDate(Date()) )")
                 
                if let next = nextMedication {
                    VStack {
                        FootLineText("Nachstes Medikament für Heute:") 
                        FootLineText("\(next.medication.name) um \(next.intakeTime.formatTimeToHHmm) Uhr")
                    }
                } else {
                    VStack { 
                        FootLineText("Du hast bereits alles Eingenommen!")
                    }
                }
            }
            
            VStack(spacing: 10) {
                ForEach(medications) { medication in
                    HStack {
                        FootLineText(medication.name)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        let sortedIntakeTimes = medication.intakeTimes.sorted(by: {
                            $0.intakeTime.toDate! < $1.intakeTime.toDate!
                        })
                        
                        let formattedIntakeTimes = sortedIntakeTimes.map { "\($0.intakeTime)" }.joined(separator: ", ") + " Uhr"
                         
                        FootLineText(formattedIntakeTimes)
                    }
                }
            }
        }
        .padding(theme.layout.padding)
        .foregroundStyle(theme.color.onBackground)
        .sectionShadow(margin: theme.layout.padding)
        .onAppear {
            nextMedication = MedicationDataService.findNextMedicationIntake(medications: medications)
        }
        .onChange(of: medications) {
            nextMedication = MedicationDataService.findNextMedicationIntake(medications: medications)
        }
    }
}
