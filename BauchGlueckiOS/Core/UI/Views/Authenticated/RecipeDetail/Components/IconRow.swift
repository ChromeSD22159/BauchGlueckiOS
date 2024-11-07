//
//  IconRow.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 07.11.24.
//
import SwiftUI

struct IconRow: View {
    let kcal: Double
    let fat: Double
    let protein: Double
    
    var body: some View {
        HStack {
            Spacer()
            
            NutrinIcon(uiImage: .fatDrop, nutrin: kcal)
            
            Spacer()
            
            NutrinIcon(uiImage: .fatDrop, nutrin: fat)
            
            Spacer()
            
            NutrinIcon(systemName: "fish", nutrin: protein)
            
            Spacer()
            
        }
    }
}
