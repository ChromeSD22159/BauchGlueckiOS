//
//  SyncHistory.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.10.24.
//

import SwiftData
import Foundation

@Model
class SyncHistory {
    @Attribute(.unique)
    var id: UUID
    var deviceId: String
    var table: String
    var lastSync: Int64 = Date().timeIntervalSince1970Milliseconds
    
    init(
        id: UUID = UUID(),
        deviceId: String = "",
        table: String = Entitiy.COUNTDOWN_TIMER.rawValue,
        lastSync: Int64 = Date().timeIntervalSince1970Milliseconds
    ) {
        self.id = id
        self.deviceId = deviceId
        self.table = table
        self.lastSync = lastSync
    }
}

