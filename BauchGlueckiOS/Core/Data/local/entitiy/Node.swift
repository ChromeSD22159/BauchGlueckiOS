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
    var text: String = ""
    var nodeId: String = UUID().uuidString
    var userID: String = ""
    var date: Int64 = Date().timeIntervalSince1970Milliseconds
    var moodsRawValue: String = "[]"
    
    init(id: UUID, text: String, userID: String, date: Int64, moodsRawValue: String) {
        self.id = id
        self.text = text
        self.userID = userID
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
