//
//  MedicationCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct MedicationCard: View {

    let theme = Theme.shared
    @Bindable var medication: Medication
    @Environment(\.modelContext) var modelContext
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
        .padding(theme.padding)
        .background(theme.surface)
        .cornerRadius(theme.radius)
        .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
    }
    
    // Header view for MedicationCard
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Image(systemName: "pills.fill")
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(medication.name)
                    .font(theme.headlineTextSmall)
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
    @ViewBuilder
    private func intakeTimesView() -> some View {
        HStack {
            Spacer()
            
            let sortedMedicationIntakeTimes = $medication.intakeTimes.sorted(by: {
                $0.intakeTime.wrappedValue.toDate! < $1.intakeTime.wrappedValue.toDate!
            })
            
            ForEach(sortedMedicationIntakeTimes) { $intakeTime in
                intakeTimeView(intakeTime: $intakeTime)
            }
        }
    }
    
    // View for a single intake time
    @ViewBuilder
    private func intakeTimeView(intakeTime: Binding<IntakeTime>) -> some View {
        let isTaken = intakeTime.wrappedValue.intakeStatuses.contains { $0.isTaken }
    
        VStack {
            ZStack {
                Circle()
                    .strokeBorder(theme.backgroundGradient, lineWidth: 5)
                    .frame(width: 80)
                Circle()
                    .fill(theme.backgroundGradient)
                    .frame(width: 50)
            }
            .opacity(isTaken ? 1.0 : 0.5)
            
            Text(intakeTime.intakeTime.wrappedValue)
                .font(.caption2)
        }
        .onTapGesture {
            toggleIntakeStatus(for: intakeTime)
        }
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
    
    // Toggles the intake status for a given intake time
    private func toggleIntakeStatus(for intakeTime: Binding<IntakeTime>) {
        if let index = intakeTime.wrappedValue.intakeStatuses.firstIndex(where: {
            Calendar.current.isDate($0.date.toDate, inSameDayAs: Date())
        }) {
            // Update existing intake status
            print("update")
            let state = intakeTime.wrappedValue.intakeStatuses[index].isTaken
            intakeTime.wrappedValue.intakeStatuses[index].isTaken = !state
            intakeTime.wrappedValue.intakeStatuses[index].updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
        } else {
            // Create new intake status for today
            print("create")
            let newStatus = IntakeStatus(
                intakeStatusId: UUID().uuidString,
                intakeTimeId: intakeTime.wrappedValue.intakeTimeId,
                date: Date().timeIntervalSince1970Milliseconds,
                isTaken: true,
                isDeleted: false,
                updatedAtOnDevice: Date().timeIntervalSince1970Milliseconds,
                intakeTime: intakeTime.wrappedValue
            )
            intakeTime.wrappedValue.intakeStatuses.append(newStatus)
        }
    }
}
