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
    @State var isSheetPresented = false
    
    let options = [
        DropDownOption(icon: "pencil", displayText: "Bearbeiten"),
        DropDownOption(icon: "trash", displayText: "Löschen")
    ]
    
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title)
                
                VStack {
                    Text(medication.name)
                        .font(theme.headlineTextSmall)
                    Text(medication.dosage)
                        .font(.footnote)
                }
                
                Spacer()
                
                DropDownComponent(options: options) { item in
                    if(item.displayText == "Löschen") {
                        onDelete()
                    }
                    if(item.displayText == "Bearbeiten") {
                        isSheetPresented = !isSheetPresented
                    }
                }
            }
            
            HStack {
                Spacer()
                ForEach(medication.intakeTimes) { intakeTime in
                    VStack {
                        ZStack {
                            Circle()
                                .strokeBorder(theme.backgroundGradient, lineWidth: 5)
                                .frame(width: 80)
                            Circle()
                                .fill(theme.backgroundGradient)
                                .frame(width: 50)
                        }
                        
                        Text(intakeTime.intakeTime)
                            .font(.caption2)
                    }
                }
            }
        }
        .sheet(isPresented: $isSheetPresented, onDismiss: {}, content: {
            EditMedicationSheet(medication: medication)
        })
        .padding(theme.padding)
        .background(theme.surface)
        .cornerRadius(theme.radius)
        .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
    }
}
