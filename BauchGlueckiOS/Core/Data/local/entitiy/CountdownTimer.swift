//
//  CountdownTimer.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

import SwiftData
import Foundation

@Model
class CountdownTimer: Identifiable {
    @Attribute(.unique) var id: UUID
    var timerID: String
    var userID: String
    var name: String
    var duration: Int
    var startDate: Int64?
    var endDate: Int64?
    var timerState: String
    var showActivity: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    var createdAt: String
    var updatedAt: String
    
    init(
        id: UUID = UUID(),
        timerID: String,
        userID: String,
        name: String,
        duration: Int64,
        startDate: Int64? = nil,
        endDate: Int64? = nil,
        timerState: String,
        showActivity: Bool,
        isDeleted: Bool,
        updatedAtOnDevice: Int64,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.timerID = timerID
        self.userID = userID
        self.name = name
        self.duration = Int(duration)
        self.startDate = startDate
        self.endDate = endDate
        self.timerState = timerState
        self.showActivity = showActivity
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension TimerState {
    var toTimerStateString: String {
        return self.value
    }
}

extension CountdownTimer {
    
    var toTimerState: TimerState {
        get {
            return TimerState.fromValue(self.timerState)
        }
        set {
            timerState = newValue.value
        }
    }
    
    func toCountdownTimerResponse() -> CountdownTimerResponse {
        return CountdownTimerResponse(
            id: 0, // ID kann optional sein oder angepasst werden, falls erforderlich
            timerID: self.timerID,
            userID: self.userID,
            name: self.name,
            duration: Int64(self.duration), // Du wandelst die Int-Dauer in Int64 um
            startDate: self.startDate,
            endDate: self.endDate,
            timerState: self.timerState,
            showActivity: self.showActivity,
            isDeleted: self.isDeleted,
            updatedAtOnDevice: self.updatedAtOnDevice,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    func update() {
        self.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
    }
}

enum TimerState: String, CaseIterable {
    case running, paused, completed, notRunning

    var value: String {
        return self.rawValue
    }

    static func fromValue(_ value: String) -> TimerState {
        return TimerState(rawValue: value) ?? .notRunning
    }
    
    var state: Int {
        return switch self {
            case .running: 1
            case .paused: 2
            case .completed: 0
            case .notRunning: 3
        }
    }
}
