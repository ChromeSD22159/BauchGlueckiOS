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
    let sugar: Double
    let horizontalCenter: Bool
    
    init(kcal: Double, fat: Double, protein: Double, sugar: Double, horizontalCenter: Bool = true) {
        self.kcal = kcal
        self.fat = fat
        self.protein = protein
        self.sugar = sugar
        self.horizontalCenter = horizontalCenter
    }
    
    var body: some View {
        HStack {
            if horizontalCenter {
                Spacer()
            }
         
            
            NutrinIcon(systemName: "bolt", nutrin: kcal)
            
            Spacer()
            
            NutrinIcon(uiImage: .fatDrop, nutrin: fat)
            
            Spacer()
            
            NutrinIcon(icon: "sugar", nutrin: sugar)
            
            Spacer()
            
            NutrinIcon(systemName: "fish", nutrin: protein)
            
            if horizontalCenter {
                Spacer()
            }
            
        }
    }
}
