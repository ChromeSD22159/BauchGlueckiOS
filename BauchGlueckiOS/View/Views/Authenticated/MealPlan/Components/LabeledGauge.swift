//
//  LabeledGauge.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 05.11.24.
//
import SwiftUI

struct LabeledGauge: View {
    @Environment(\.theme) private var theme
    
    var current: Double
    var minValue: Double
    var maxValue: Double
    
    var body: some View {
        Gauge(value: current, in: minValue...maxValue) {
            Text("BPM")
        }
        .tint(theme.color.primary)
        .padding(.horizontal, 15)
        .gaugeStyle(.accessoryLinear)
    }
}
