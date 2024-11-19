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
    let theme: Theme = Theme.shared
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
    let theme: Theme = Theme.shared
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
                Text("Medikamente für \( DateFormatteUtil.formattedFullDate(Date()) )")
                    .font(theme.headlineTextSmall)
                
                
                
                if let next = nextMedication {
                    VStack {
                        Text("Nachstes Medikament für Heute:")
                            .font(.footnote)
                        
                        Text("\(next.medication.name) um \(next.intakeTime.formatTimeToHHmm) Uhr")
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
            nextMedication = MedicationDataService.findNextMedicationIntake(medications: medications)
        }
        .onChange(of: medications) {
            nextMedication = MedicationDataService.findNextMedicationIntake(medications: medications)
        }
    }
}
