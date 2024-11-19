//
//  awaitAction.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 24.10.24.
//
import SwiftUI
 
struct DelayUtil {
    static func awaitAction(
        seconds: Int,
        startAction: () -> Void = {},
        delayedAction: () -> Void = {}
    ) async throws {
        startAction()
        try await Task.sleep(for: .seconds(seconds))
        delayedAction()
    } 
}
