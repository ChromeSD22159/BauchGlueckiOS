//
//  WeightometerGaugeStyle.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//
import SwiftUI

struct WeightOmeterGaugeStyle: GaugeStyle { 
    @Environment(\.theme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            
            Circle()
                .foregroundColor(Color(.systemGray6))

            Circle()
                .trim(from: 0, to: 1)
                .stroke(theme.color.surface, lineWidth: 15)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0, to: 0.75 * configuration.value)
                .stroke(theme.color.backgroundGradient, lineWidth: 15)
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .round, dash: [1, 34], dashPhase: 0.0))
                .rotationEffect(.degrees(-90))

            VStack {
                configuration.currentValueLabel
                   
                
                Text("KG")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(theme.color.primary)
            }

        }
        .frame(width: 250, height: 250)

    }

}
