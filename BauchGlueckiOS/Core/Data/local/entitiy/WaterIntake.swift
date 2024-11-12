//
//  WaterIntake.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//

import SwiftData
import Foundation

@Model
class WaterIntake: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var userId: String
    var waterIntakeId: String
    var value: Double
    var isDeleted: Bool
    var updatedAtOnDevice: Int64
    
    init(
        id: UUID = UUID(),
        userId: String,
        waterIntakeId: String = UUID().uuidString,
        value: Double = 0.25,
        isDeleted: Bool = false,
        updatedAtOnDevice: Int64 = Date().timeIntervalSince1970Milliseconds
    ) {
        self.id = id
        self.userId = userId
        self.waterIntakeId = waterIntakeId
        self.value = value
        self.isDeleted = isDeleted
        self.updatedAtOnDevice = updatedAtOnDevice
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case waterIntakeId
        case value
        case isDeleted
        case updatedAtOnDevice
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = UUID(uuidString: String(intId)) ?? UUID()
        } else if let stringId = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: stringId) ?? UUID()
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "ID could not be decoded")
        }
        
        self.userId = (try? container.decode(String.self, forKey: .userId)) ?? ""
        self.waterIntakeId = (try? container.decode(String.self, forKey: .waterIntakeId)) ?? ""
        self.value = (try? container.decode(Double.self, forKey: .value)) ?? 0.0
        self.isDeleted = (try? container.decode(Bool.self, forKey: .isDeleted)) ?? false
        self.updatedAtOnDevice = (try? container.decode(Int64.self, forKey: .updatedAtOnDevice)) ?? Date().timeIntervalSince1970Milliseconds
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(userId, forKey: .userId)
            try container.encode(waterIntakeId, forKey: .waterIntakeId)
            try container.encode(Float(value), forKey: .value)
            try container.encode(isDeleted, forKey: .isDeleted)
            try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        } catch {
            print("Error Encoding WaterIntake")
        }
    }
}

extension WaterIntake {
    func update() {
        self.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
    }
}
