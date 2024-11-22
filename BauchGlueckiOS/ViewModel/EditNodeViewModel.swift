//
//  EditNodeViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 21.11.24.
//
import SwiftData
import SwiftUI

@Observable
class EditNodeViewModel: ObservableObject {
    var note: Node
    var allMoods: [Mood]
    var maxCharacters: Int
    
    init(note: Node, allMoods: [Mood], maxCharacters: Int) {
        self.note = note
        self.allMoods = allMoods
        self.maxCharacters = maxCharacters
    }
    
    var textFieldDisplayLength: String {
        "\(note.text.count)/\(maxCharacters)"
    }
    
    func onClickOnMood(mood: Mood) {
        if currentMoodListContainsMood(mood: mood) {
            removeMood(mood: mood)
            updateMoodFromDataList(mood: mood, value: false)
        } else {
            addMood(mood: mood)
            updateMoodFromDataList(mood: mood, value: true)
        }
    }
    
    func currentMoodListContainsMood(mood: Mood) -> Bool {
        let moodDisplay = mood.display.lowercased()
        return note.moods.contains(where: { $0.display.lowercased() == moodDisplay })
    }
    
    private func addMood(mood: Mood) {
        var listCopy = note.moods
        listCopy.append(mood)
        
        if let jsonString = toJsonString(data: listCopy) {
            note.moodsRawValue = jsonString
        }
    }
    
    private func removeMood(mood: Mood) {
        var listCopy = note.moods
        if let index = listCopy.firstIndex(where: { $0.display.lowercased() == mood.display.lowercased() }) {
            listCopy.remove(at: index)
        }
        
        if let jsonString = toJsonString(data: listCopy) {
            note.moodsRawValue = jsonString
        }
    }
    
    private func updateMoodFromDataList(mood: Mood, value: Bool) {
        if let index = allMoods.firstIndex(where: { $0.display.lowercased() == mood.display.lowercased() }) {
            var updatedMood = allMoods[index]
            updatedMood.isOnList = value
            allMoods[index] = updatedMood
        }
    }
    
    func saveNote(modelContext: ModelContext) throws {
        do {
            try modelContext.save()
        } catch {
            throw DatabaseError.insertFailed(NSLocalizedString("Es trat ein Fehler beim Einfügen der Daten auf.", comment: "Einfügen Fehler"))
        }
    }
}
