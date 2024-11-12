//
//  Medication.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

@Model
class Medication: Codable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var medicationId: String
    @Attribute var userId: String
    @Attribute var name: String
    @Attribute var dosage: String
    @Attribute var isDeleted: Bool
    @Attribute var updatedAtOnDevice: Int64
    
    @Relationship(deleteRule: .cascade) var intakeTimes: [IntakeTime]
    
    init(id: UUID = UUID(), medicationId: String, userId: String, name: String, dosage: String, isDeleted: Bool, updatedAtOnDevice: Int64, intakeTimes: [IntakeTime] = []) {
        self.id = id
        self.medicationId = medicationId
        self.userId = userId
        self.name = name
        self.dosage = dosage
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.intakeTimes = intakeTimes
    }
    
    private enum CodingKeys: String, CodingKey {
        case medicationId, userId, name, dosage, isDeleted, updatedAtOnDevice
        case strapiId = "id"
        case intakeTimes = "intake_times"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
         
        self.id = UUID()
        
        self.medicationId = try container.decode(String.self, forKey: .medicationId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.dosage = try container.decode(String.self, forKey: .dosage)
        self.isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        self.updatedAtOnDevice = Int64(try container.decode(String.self, forKey: .updatedAtOnDevice)) ?? 0
        self.intakeTimes = try container.decodeIfPresent([IntakeTime].self, forKey: .intakeTimes) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Strapi benötigt keine UUID-basierte ID, daher wird sie nicht codiert
        try container.encode(medicationId, forKey: .medicationId)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(dosage, forKey: .dosage)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(intakeTimes, forKey: .intakeTimes)
    }
}

@Model
class IntakeTime: Codable {
    @Attribute(.unique) var id: UUID
    var intakeTimeId: String
    var intakeTime: String
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    
    @Relationship(inverse: \Medication.intakeTimes) var medication: Medication?
    
    @Relationship(deleteRule: .cascade) var intakeStatuses: [IntakeStatus]
    
    init(id: UUID = UUID(), intakeTimeId: String, intakeTime: String, medicationId: String, isDeleted: Bool, updatedAtOnDevice: Int64, medication: Medication?, intakeStatuses: [IntakeStatus] = []) {
        self.id = id
        self.intakeTimeId = intakeTimeId
        self.intakeTime = intakeTime
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
        self.intakeStatuses = intakeStatuses
        self.intakeTime = intakeTime
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, intakeTimeId, intakeTime, isDeleted, updatedAtOnDevice, medication
        case intakeStatuses = "intake_statuses"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
         
        self.id = UUID()
        self.intakeTimeId = try container.decode(String.self, forKey: .intakeTimeId)
        self.intakeTime = try container.decode(String.self, forKey: .intakeTime)
        self.isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
        self.updatedAtOnDevice = Int64(try container.decode(String.self, forKey: .updatedAtOnDevice)) ?? 0
        self.intakeStatuses = try container.decode([IntakeStatus].self, forKey: .intakeStatuses)
        self.intakeTime = try container.decode(String.self, forKey: .intakeTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
         
        try container.encode(intakeTimeId, forKey: .intakeTimeId)
        try container.encode(intakeTime, forKey: .intakeTime)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(intakeStatuses, forKey: .intakeStatuses)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(intakeTime, forKey: .intakeTime)
    }
}

@Model
class IntakeStatus: Codable {
    @Attribute(.unique) var intakeStatusId: String
    var intakeTimeId: String
    var date: Int64
    var isTaken: Bool
    var updatedAtOnDevice: Int64

    @Relationship(inverse: \IntakeTime.intakeStatuses) var intakeTime: IntakeTime?

    init(intakeStatusId: String, intakeTimeId: String, date: Int64, isTaken: Bool, updatedAtOnDevice: Int64, intakeTime: IntakeTime) {
        self.intakeStatusId = intakeStatusId
        self.intakeTimeId = intakeTimeId
        self.date = date
        self.isTaken = isTaken
        self.updatedAtOnDevice = updatedAtOnDevice
        self.intakeTime = intakeTime
    }
    
    private enum CodingKeys: String, CodingKey {
        case intakeStatusId, intakeTimeId, date, isTaken, updatedAtOnDevice, intakeTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
          
        self.intakeStatusId = try container.decode(String.self, forKey: .intakeStatusId)
        self.intakeTimeId = try container.decodeIfPresent(String.self, forKey: .intakeTimeId) ?? ""
        self.date = Int64(try container.decode(String.self, forKey: .date)) ?? 0
        self.isTaken = try container.decode(Bool.self, forKey: .isTaken)
        self.updatedAtOnDevice = Int64(try container.decode(String.self, forKey: .updatedAtOnDevice)) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
         
        try container.encode(intakeStatusId, forKey: .intakeStatusId)
        try container.encode(intakeTimeId, forKey: .intakeTimeId)
        try container.encode(date, forKey: .date)
        try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        try container.encode(intakeTime, forKey: .intakeTime)
    }
}

 








struct MedicationDTO: Codable {
    var medicationId: String
    var userId: String
    var name: String
    var dosage: String
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    var intake_times: [IntakeTimeDTO]  // Strapi erwartet `intake_times`
}

struct IntakeTimeDTO: Codable {
    var intakeTimeId: String
    var intakeTime: String
    var medicationId: String
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    var intake_statuses: [IntakeStatusDTO] // Strapi erwartet `intake_statuses`
}

struct IntakeStatusDTO: Codable {
    var intakeStatusId: String
    var intakeTimeId: String
    var date: Int64
    var isTaken: Bool
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
}
