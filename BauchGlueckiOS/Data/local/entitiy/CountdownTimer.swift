//
//  CountdownTimer.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

import SwiftData
import Foundation

@Model
class CountdownTimer: Codable {
    @Attribute(.unique)
    var id: Int = 0
    var timerId: String = ""
    var userId: String = ""
    var name: String = ""
    var duration: Int64 = 0
    var startDate: Int64? = nil
    var endDate: Int64? = nil
    var timerState: String = ""
    var showActivity: Bool = true
    var isDeleted: Bool = false
    var updatedAtOnDevice: Int64 = Date().timeIntervalSince1970Milliseconds
    var createdAt: String = ISO8601DateFormatter().string(from: Date())
    var updatedAt: String = ISO8601DateFormatter().string(from: Date())
    
    // Initialisierer
    init(
        id: Int = 0,
        timerId: String = "",
        userId: String = "",
        name: String = "",
        duration: Int64 = 0,
        startDate: Int64? = nil,
        endDate: Int64? = nil,
        timerState: String = "",
        showActivity: Bool = true,
        isDeleted: Bool = false,
        createdAt: String = ISO8601DateFormatter().string(from: Date()),
        updatedAt: String = ISO8601DateFormatter().string(from: Date())
    ) {
        self.id = id
        self.timerId = timerId
        self.userId = userId
        self.name = name
        self.duration = duration
        self.startDate = startDate
        self.endDate = endDate
        self.timerState = timerState
        self.showActivity = showActivity
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
    }
    
    enum CodingKeys: String, CodingKey {
        case id, timerId, userId, name, duration, startDate, endDate, timerState, showActivity, isDeleted, updatedAtOnDevice, createdAt, updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.timerId = try container.decode(String.self, forKey: .timerId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.duration = try container.decode(Int64.self, forKey: .duration)
        self.startDate = try container.decodeIfPresent(Int64.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Int64.self, forKey: .endDate)
        self.timerState = try container.decode(String.self, forKey: .timerState)
        self.showActivity = try container.decode(Bool.self, forKey: .showActivity)
        self.isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        self.updatedAtOnDevice = try container.decode(Int64.self, forKey: .updatedAtOnDevice)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(timerId, forKey: .timerId)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(timerState, forKey: .timerState)
        try container.encode(showActivity, forKey: .showActivity)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

func dateStringToMilliseconds(_ dateString: String) -> Int64 {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: dateString) {
        return Int64(date.timeIntervalSince1970 * 1000)
    }
    return 0
}

extension CountdownTimer {
    var toCreatedAtLong: Int64 {
        return dateStringToMilliseconds(self.createdAt)
    }

    var toUpdateAtLong: Int64 {
        return dateStringToMilliseconds(self.updatedAt)
    }
    
    var toTimerState: TimerState {
        get {
            return TimerState.fromValue(self.timerState)
        }
        set {
            timerState = newValue.value
        }
    }
}

enum TimerState: String {
    case running = "running"
    case paused = "paused"
    case completed = "completed"
    case notRunning = "notRunning"

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

extension Date {
    var timeIntervalSince1970Milliseconds: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
