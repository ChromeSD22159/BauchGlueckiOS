//
//  TimerSettings.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//

struct TimerSettings {
    var durationRange: ClosedRange<Int> // 0 sek - 90 * 60 sek
    var stepsEach: Int // 1 * 60
    var buttonStepsEach: Int // 5
}

extension TimerSettings {
    var stepsInSeconds: [Int] {
        stride(from: durationRange.lowerBound, to: durationRange.upperBound + buttonStepsEach, by: buttonStepsEach).map { $0 }
    }
}
