//
//  WeightometerGaugeStyle.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//
import SwiftUI

struct WeightOmeterGaugeStyle: GaugeStyle {
    let theme: Theme = Theme.shared

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            
            Circle()
                .foregroundColor(Color(.systemGray6))

            Circle()
                .trim(from: 0, to: 1)
                .stroke(theme.surface, lineWidth: 15)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0, to: 0.75 * configuration.value)
                .stroke(theme.backgroundGradient, lineWidth: 15)
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .round, dash: [1, 34], dashPhase: 0.0))
                .rotationEffect(.degrees(-90))

            VStack {
                configuration.currentValueLabel
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.onPrimary)
                
                Text("KG")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(theme.primary)
            }

        }
        .frame(width: 250, height: 250)

    }

}
