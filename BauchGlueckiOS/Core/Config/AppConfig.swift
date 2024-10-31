//
//  AppConfig.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//
import SwiftUI

class AppConfig {
    static var shared = AppConfig()
    
    let timerConfig = TimerSettings(durationRange: 0...(60 * 90), stepsEach: (60 * 1), buttonStepsEach: (60 * 5))
    let weightConfig = WeightSettings(weightRange: 50.0...400.0, stepsEach: 0.1, buttonStepsEach: 10.0)
}


