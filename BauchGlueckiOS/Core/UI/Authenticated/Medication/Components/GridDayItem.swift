//
//  GridDayItem.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 30.10.24.
//
import SwiftUI

struct GridDayItem: View {
    var cellSize: CGFloat
    var percent: CGFloat
    
    init(cellSize: CGFloat, timesCount: Int, intakeCount: Int) {
        self.cellSize = cellSize
        
        if intakeCount > 0 {
            percent = (CGFloat(intakeCount) / CGFloat(timesCount) * 100)
        } else {
            percent = 0
        }
    }
    
    init(cellSize: CGFloat, percent: Int) {
        self.cellSize = cellSize
        self.percent = Double(percent)
    }
    
    var body: some View {
        ZStack {
            if percent == 0.0 {
                Color.gray
            } else {
                Theme.shared.primary
            }
        }
        .opacity(percent == 0.0 ? 0.5 : scaledOutputValue(start: 0.5, percentage: percent))
        .frame(width: cellSize, height: cellSize)
        .cornerRadius(5)
    }
    
    private func scaledOutputValue(start: CGFloat = 0.4, percentage value: CGFloat) -> CGFloat {
        let max = 1.0
        let diff = max - start
        return start + (value / 100.0 * diff)
    }
}
