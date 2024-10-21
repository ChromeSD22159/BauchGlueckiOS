//
//  CountdownTimerResponse.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//

import Foundation

struct CountdownTimerResponse: Codable {
    var id: Int
    var timerID: String
    var userID: String
    var name: String
    var duration: Int64
    var startDate: Int64?
    var endDate:  Int64?
    var timerState: String
    var showActivity: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    var createdAt: String
    var updatedAt: String

    // CodingKeys, um die korrekten JSON-Schlüssel zu definieren
    enum CodingKeys: String, CodingKey {
        case id
        case timerID = "timerId" // Mapping des JSON-Schlüssels "timerId" auf das Feld "timerID"
        case userID = "userId"   // Mapping des JSON-Schlüssels "userId" auf das Feld "userID"
        case name
        case duration
        case startDate
        case endDate
        case timerState
        case showActivity
        case isDeleted
        case updatedAtOnDevice
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.timerID = try container.decode(String.self, forKey: .timerID)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.name = try container.decode(String.self, forKey: .name)
        self.timerState = try container.decode(String.self, forKey: .timerState)
        self.showActivity = try container.decode(Bool.self, forKey: .showActivity)
        self.isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        if let durationString = try? container.decodeIfPresent(String.self, forKey: .duration),
            let duration = Int64(durationString) {
            self.duration = duration
        } else {
            self.duration = 0
        }
        
        if let updatedAtOnDeviceString = try? container.decodeIfPresent(String.self, forKey: .updatedAtOnDevice),
            let updatedAtOnDevice = Int64(updatedAtOnDeviceString) {
            self.updatedAtOnDevice = updatedAtOnDevice
        } else {
            self.updatedAtOnDevice = 0
        }
        
        // Custom decoding for startDate and endDate
        if let startDateString = try? container.decodeIfPresent(String.self, forKey: .startDate),
           let startDateInt = Int64(startDateString) {
            self.startDate = startDateInt
        } else {
            self.startDate = nil
        }
        
        if let endDateString = try? container.decodeIfPresent(String.self, forKey: .endDate),
           let endDateInt = Int64(endDateString) {
            self.endDate = endDateInt
        } else {
            self.endDate = nil
        }
    }
    
    init(
        id: Int,
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
        self.duration = duration
        self.startDate = startDate
        self.endDate = endDate
        self.timerState = timerState
        self.showActivity = showActivity
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension CountdownTimerResponse {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(timerID, forKey: .timerID)
        try container.encode(userID, forKey: .userID)
        try container.encode(name, forKey: .name)
        try container.encode(duration, forKey: .duration)
        try container.encode(timerState, forKey: .timerState)
        try container.encode(showActivity, forKey: .showActivity)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)

        // Custom encoding for startDate and endDate as Int64 or null
        if let startDate = startDate {
            try container.encode(String(startDate), forKey: .startDate)
        } else {
            try container.encodeNil(forKey: .startDate)
        }
        
        if let endDate = endDate {
            try container.encode(String(endDate), forKey: .endDate)
        } else {
            try container.encodeNil(forKey: .endDate)
        }
    }
    
    func toCountdownTimer() -> CountdownTimer {
        return CountdownTimer(
            timerID: self.timerID,
            userID: self.userID,
            name: self.name,
            duration: self.duration,
            timerState: self.timerState,
            showActivity: self.showActivity,
            isDeleted: self.isDeleted,
            updatedAtOnDevice: self.updatedAtOnDevice,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
