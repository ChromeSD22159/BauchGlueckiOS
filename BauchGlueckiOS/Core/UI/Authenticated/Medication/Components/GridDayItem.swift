//
//  GridDayItem.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct GridDayItem: View {
    var cellSize: CGFloat
    var percent: Double
    
    init(cellSize: CGFloat, timesCount: Int, intakeCount: Int) {
        self.cellSize = cellSize
        
        if intakeCount > 0 {
            percent = Double(intakeCount) / Double(timesCount) * 100
        } else {
            percent = 0
        }
    }
    
    init(cellSize: CGFloat, percent: Double) {
        self.cellSize = cellSize
        self.percent = percent
    }
    
    var body: some View {
        ZStack {
            if percent > 0.0 {
                Theme.shared.primary.opacity(percent)
            } else {
                Color.gray.opacity(0.25)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .cornerRadius(5)
    }
}
