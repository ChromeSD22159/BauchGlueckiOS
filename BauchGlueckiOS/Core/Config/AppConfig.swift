//
//  AppConfig.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//
import SwiftUI

class AppConfig {
    static var shared = AppConfig()
    
    let timerConfig = TimerSettings(durationRange: 0...(60 * 90), stepsEach: (60 * 1))
}


