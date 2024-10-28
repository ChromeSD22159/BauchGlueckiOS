//
//  AddNodeViewModel.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.10.24.
//
import SwiftUI
import SwiftData

@Observable
class AddNodeViewModel: ObservableObject {
    
    private let maxCharacters = 512
    var modelContext: ModelContext
    
    var allMoods: [Mood] = []
    var currentMoods: [Mood] = []
    var node: String = ""
    var message: String = ""
    var currentNote: Node? = nil
    
    var textFieldDisplayLength: String {
        "\(message.count)/\(self.maxCharacters)"
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.allMoods = Moods.list
    }
    
    private func showMessage(error: String) {
        if (error.count <= maxCharacters) {
            Task {
                message = error
                
                sleep(5_000_000)
                
                message = ""
            }
        }
    }
    
    func saveNode(finished: @escaping () -> Void = {}) {
        do {
            let jsonData = try JSONEncoder().encode(currentMoods)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                Task {
                    modelContext.insert(
                        Node(
                            id: UUID(),
                            text: node,
                            userID: UUID().uuidString,
                            date: Date().timeIntervalSince1970Milliseconds,
                            moodsRawValue: jsonString
                        )
                    )
                    
                    showMessage(error: "Gespeichert")
                    
                    sleep(1_000_000)
                    
                    finished()
                }
                
            }
        } catch {
            print("Fehler beim Kodieren der Daten: \(error)")
        }
    }
    
    func updateNodeText(text: String) {
        if (text.count <= maxCharacters) {
            node = text
        }
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
    
    func setNodeID(nodeId: String) {
        let predicate = #Predicate<Node> { node in
            node.nodeId == nodeId
        }
        
        let fetch = FetchDescriptor(predicate: predicate)
        
        do {
            let node = try modelContext.fetch(fetch)
            
            if let node = node.first {
                self.node = node.text
                self.currentNote = node
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func formattedDate(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM.yyyy"
        
        return formatter.string(from: date)
    }
}
