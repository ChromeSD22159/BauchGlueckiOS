//
//  Weight.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//
import SwiftData
import Foundation

@Model
class Weight: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var userID: String
    var weightId: String
    var value: Double
    var isDeleted: Bool
    var weighed: String
    var updatedAtOnDevice: Int64
    
    init(
        id: UUID = UUID(),
        userID: String = "",
        weightId: String = "",
        value: Double = 0.0,
        isDeleted: Bool = false,
        weighed: String = "",
        updatedAtOnDevice: Int64 = Date().timeIntervalSince1970Milliseconds
    ) {
        self.id = id
        self.userID = userID
        self.weightId = weightId
        self.value = value
        self.isDeleted = isDeleted
        self.weighed = weighed
        self.updatedAtOnDevice = updatedAtOnDevice
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case weightId
        case value
        case isDeleted
        case weighed
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
        
        self.userID = (try? container.decode(String.self, forKey: .userID)) ?? ""
        self.weightId = (try? container.decode(String.self, forKey: .weightId)) ?? ""
        self.value = (try? container.decode(Double.self, forKey: .value)) ?? 0.0
        self.isDeleted = (try? container.decode(Bool.self, forKey: .isDeleted)) ?? false
        self.weighed = (try? container.decode(String.self, forKey: .weighed)) ?? ""
        self.updatedAtOnDevice = (try? container.decode(Int64.self, forKey: .updatedAtOnDevice)) ?? Date().timeIntervalSince1970Milliseconds
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(userID, forKey: .userID)
            try container.encode(weightId, forKey: .weightId)
            try container.encode(value, forKey: .value)
            try container.encode(isDeleted, forKey: .isDeleted)
            try container.encode(weighed, forKey: .weighed)
            try container.encode(updatedAtOnDevice, forKey: .updatedAtOnDevice)
        } catch {
            print("Error Encoding Weight")
        }
    }
}

extension Weight {
    func update() {
        self.updatedAtOnDevice = Date().timeIntervalSince1970Milliseconds
    }
}
