//
//  MedicationCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct MedicationCard: View {
    @Bindable var medication: Medication
    
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var services: Services
    
    @State var isSheetPresented = false
    
    let options = [
        DropDownOption(icon: "pencil", displayText: "Bearbeiten"),
        DropDownOption(icon: "trash", displayText: "Löschen"),
        DropDownOption(icon: "trash", displayText: "Delete Intakes DB")
    ]
    
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            headerView()
            intakeTimesView()
        }
        .sheet(isPresented: $isSheetPresented) {
            EditMedicationSheet(medication: medication)
        }
        .padding(theme.layout.padding)
        .background(theme.color.surface)
        .cornerRadius(theme.layout.radius)
        .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
    }
    
    // Header view for MedicationCard
    @ViewBuilder private func headerView() -> some View {
        HStack {
            Image(systemName: "pills.fill")
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(medication.name)
                    .font(theme.font.headlineTextSmall)
                Text(medication.dosage)
                    .font(.footnote)
            }
            
            Spacer()
            
            DropDownComponent(options: options) { item in
                handleDropDownSelection(item: item)
            }
        }
    }
    
    // View for displaying intake times
    @ViewBuilder private func intakeTimesView() -> some View {
        HStack {
            Spacer()
            
            let sortedMedicationIntakeTimes = medication.intakeTimes.sorted(by: {
                $0.intakeTime.toDate! < $1.intakeTime.toDate!
            })
            
            ForEach(sortedMedicationIntakeTimes) { intakeTime in
                intakeTimeView(intakeTime: intakeTime)
            }
        }
    }
    
    // View for a single intake time
    @ViewBuilder private func intakeTimeView(@Bindable intakeTime: IntakeTime) -> some View {

        VStack {
            ZStack {
                Circle()
                    .strokeBorder(theme.color.backgroundGradient, lineWidth: 5)
                    .frame(width: 80)
                
                Circle()
                    .fill(theme.color.backgroundGradient)
                    .frame(width: 50)
            }
            .opacity(isTakentoday(intakeTime: intakeTime) ? 1.0 : 0.5)
            
            Text(intakeTime.intakeTime)
                .font(.caption2)
        }
        .onTapGesture {
            MedicationDataService.toggleIntakeStatus(for: intakeTime)
            
            services.medicationService.sendUpdatedMedicationToBackend()
        }
    }
    
    private func isTakentoday(intakeTime: IntakeTime) -> Bool {
        let hasEntryForToday: Bool = intakeTime.intakeStatuses.contains { status in
            Calendar.current.isDate(status.date.toDate, inSameDayAs: Date()) && !status.isDeleted
        }

        let hasUntakenForToday: Bool = intakeTime.intakeStatuses.contains { status in
            Calendar.current.isDate(status.date.toDate, inSameDayAs: Date()) && !status.isDeleted && !status.isTaken
        }

        return hasEntryForToday && !hasUntakenForToday
    }
    
    // Handles DropDown selection actions
    private func handleDropDownSelection(item: DropDownOption) {
        if item.displayText == "Löschen" {
            onDelete()
        } else if item.displayText == "Bearbeiten" {
            isSheetPresented = true
        } else if item.displayText == "Delete Intakes DB" {
            medication.intakeTimes.forEach { time in
                time.intakeStatuses.forEach {
                    modelContext.delete($0)
                }
            }
        }
    }
}


