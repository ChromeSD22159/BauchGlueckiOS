//
//  Medication.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

@Model
class Medication {
    @Attribute(.unique) var id: UUID
    @Attribute var medicationId: String
    @Attribute var userId: String
    @Attribute var name: String
    @Attribute var dosage: String
    @Attribute var isDeleted: Bool
    @Attribute var updatedAtOnDevice: Int64
    
    @Relationship(deleteRule: .cascade) var intakeTimes: [IntakeTime]
    
    init(id: UUID, medicationId: String, userId: String, name: String, dosage: String, isDeleted: Bool, updatedAtOnDevice: Int64, intakeTimes: [IntakeTime] = []) {
        self.id = id
        self.medicationId = medicationId
        self.userId = userId
        self.name = name
        self.dosage = dosage
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.intakeTimes = intakeTimes
    }
}

@Model
class IntakeTime {
    @Attribute(.unique) var id: UUID
    var intakeTimeId: String
    var intakeTime: String
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    
    @Relationship(inverse: \Medication.intakeTimes) var medication: Medication?
    
    @Relationship(deleteRule: .cascade) var intakeStatuses: [IntakeStatus]
    
    init(id: UUID, intakeTimeId: String, intakeTime: String, medicationId: String, isDeleted: Bool, updatedAtOnDevice: Int64, medication: Medication?, intakeStatuses: [IntakeStatus] = []) {
        self.id = id
        self.intakeTimeId = intakeTimeId
        self.intakeTime = intakeTime
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.intakeStatuses = intakeStatuses
        self.intakeTime = intakeTime
    }
}

@Model
class IntakeStatus {
    var intakeStatusId: String
    var intakeTimeId: String
    var date: Int64
    var isTaken: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: Int64

    @Relationship(inverse: \IntakeTime.intakeStatuses) var intakeTime: IntakeTime?
    
    init(intakeStatusId: String, intakeTimeId: String, date: Int64, isTaken: Bool, isDeleted: Bool, updatedAtOnDevice: Int64, intakeTime: IntakeTime) {
        self.intakeStatusId = intakeStatusId
        self.intakeTimeId = intakeTimeId
        self.date = date
        self.isTaken = isTaken
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.intakeTime = intakeTime
    }
}
