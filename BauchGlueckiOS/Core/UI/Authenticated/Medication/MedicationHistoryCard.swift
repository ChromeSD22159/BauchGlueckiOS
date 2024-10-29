//
//  MedicationHistoryCard.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct MedicationHistoryCard: View {
    
    let theme = Theme.shared
    
    var medication: Medication
    
    var body: some View {
        Text(medication.name)
    }
}
