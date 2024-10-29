//
//  EditNoteSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct EditNoteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var note: Node
    @Binding var allMoods: [Mood]
    let theme: Theme
    let maxCharacters: Int
    
    var textFieldDisplayLength: String {
        "\(note.text.count)/\(maxCharacters)"
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: theme.padding * 3) {
                        SheetInputField()
                        
                        ControllButton()
                        
                        MoodList()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                }
            }
        }
    }
    
    @ViewBuilder func SheetInputField() -> some View {
        VStack {
            HStack {
                Text(formattedDate(note.date.toDate))
                    .font(.footnote)
                Spacer()
            }
            VStack {
                HStack {
                    TextEditor(text: $note.text)
                        .background(theme.surface)
                        .cornerRadius(theme.radius)
                        .shadow(radius: 2)
                        .lineLimit(10, reservesSpace: true)
                        .frame(minHeight: 100)
                }
                HStack {
                    Spacer()
                    Text(textFieldDisplayLength)
                        .font(.caption)
                }
            }
        }
    }
    
    @ViewBuilder func ControllButton() -> some View {
        HStack {
            
            Spacer()
            
            IconTextButton(text: "Speichern") {
                dismiss()
            }
        }
    }
    
    @ViewBuilder func MoodList() -> some View {
        VStack {
            HStack {
                Text("Ausgewählte Moods: \(allMoods.filter { $0.isOnList == true }.count)")
                    .font(.footnote)
                
                Spacer()
            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]
            ) {
                ForEach(allMoods, id: \.display) { mood in
                    Text(mood.display)
                        .font(.footnote)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .lineLimit(1, reservesSpace: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(theme.onBackground)
                        .background(currentMoodListContainsMood(mood: mood) ? theme.primary : theme.surface )
                        .cornerRadius(100)
                        .onTapGesture { onClickOnMood(mood: mood) }
                }
            }
        }
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
    
    func formattedDate(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return formatter.string(from: date)
    }
}
