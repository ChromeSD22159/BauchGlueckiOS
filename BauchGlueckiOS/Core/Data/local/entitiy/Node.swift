//
//  Untitled.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 27.10.24.
//

import SwiftData
import Foundation

@Model
class Node {
    @Attribute(.unique) var id: UUID
    var text: String
    var userID: String
    var nodeId: String
    var date: Int64
    var moodsRawValue: String
    
    init(
        id: UUID = UUID(),
        text: String = "",
        userID: String = UUID().uuidString,
        nodeId: String = UUID().uuidString,
        date: Int64 = Date().timeIntervalSince1970Milliseconds,
        moodsRawValue: String = "[]"
    ) {
        self.id = id
        self.text = text
        self.userID = userID
        self.nodeId = nodeId
        self.date = date
        self.moodsRawValue = moodsRawValue
    }
}

extension Node {
    var dateString: String {
        date.toDate.ISO8601Format()
    }
    
    var moods: [Mood] {
        do {
           return try JSONDecoder().decode([Mood].self, from: moodsRawValue.data(using: .utf8)!)
        } catch {
           print("Fehler beim Dekodieren von moods: \(error)")
           return []
        }
    }
}

struct Mood: Codable {
    var display: String
    var isOnList: Bool = false
}
