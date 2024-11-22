//
//  AddNodeViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.10.24.
//
import SwiftUI
import SwiftData
import FirebaseAuth

@Observable
class AddNodeViewModel: ObservableObject {
    
    private let maxCharacters = 512
    var modelContext: ModelContext
    
    /// TEXTFIELD
    var noteText: String = ""
    
    var allMoods: [Mood] = []
    var currentMoods: [Mood] = []
     
    var message: String = ""
    var currentNote: Node? = nil
    
    var textFieldDisplayLength: String {
        "\(noteText.count)/\(self.maxCharacters)"
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.allMoods = Moods.list
    } 
    
    func saveNode() throws {
        guard let userID = Auth.auth().currentUser else { throw UserError.notLoggedIn }
        
        guard noteText.count > 5 else { throw NoteError.invalidText }
        
        let jsonData = try JSONEncoder().encode(currentMoods)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            let newNote = Node(
                id: UUID(),
                text: noteText,
                userID: userID.uid,
                date: Date().timeIntervalSince1970Milliseconds,
                moodsRawValue: jsonString
            )
            
            modelContext.insert(newNote)
            try modelContext.save()
        }
        
        self.showOverlayMessage(error: "Gespeichert")
    }
    
    func currentMoodListContainsMood(mood: Mood) -> Bool {
        let moodDisplay = mood.display.lowercased()
        
        return currentMoods.contains(where: { mood in
            mood.display.lowercased() == moodDisplay
        })
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
    
    private func addMood(mood: Mood) {
        currentMoods.append(mood)
    }
    
    private func removeMood(mood: Mood) {
        if let index = currentMoods.firstIndex(where: { $0.display.lowercased() == mood.display.lowercased()}) {
            currentMoods.remove(at: index)
        }
    }
     
    private func updateMoodFromDataList(mood: Mood, value: Bool) {
        if let index = allMoods.firstIndex(where: { $0.display.lowercased() == mood.display.lowercased() }) {
            var updatedMood = allMoods[index]
            updatedMood.isOnList = value
            allMoods[index] = updatedMood
        }
    }

    private func showOverlayMessage(error: String) {
        if (error.count <= maxCharacters) {
            Task {
                message = error
                
                sleep(5_000_000)
                
                message = ""
            }
        }
    }
}
