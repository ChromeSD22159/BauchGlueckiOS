//
//  WeightSettings.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 31.10.24.
//

struct WeightSettings {
    var weightRange: ClosedRange<Double>
    var stepsEach: Double
    var buttonStepsEach: Double 
}

extension WeightSettings {
    var stepsInSeconds: [Double] {
        stride(from: weightRange.lowerBound, to: weightRange.upperBound + buttonStepsEach, by: buttonStepsEach).map { $0 }
    }
}
