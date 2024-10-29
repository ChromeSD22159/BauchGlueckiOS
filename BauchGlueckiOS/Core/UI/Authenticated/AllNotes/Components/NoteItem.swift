//
//  NoteItem.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI

struct NoteItem: View {
    
    let theme: Theme = Theme.shared
    @State var note: Node
    private let maxCharacters = 512
    
    @State var sheet = false
    @State var allMoods: [Mood] = Moods.list

    var textFieldDisplayLength: String {
        "\(note.text.count)/\(maxCharacters)"
    }
    
    init(note: Node) {
       self._note = State(initialValue: note)
   }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Text(formattedDate(note.date.toDate))
                    .font(.footnote)
            }
            
            HStack {
                Text("Notiz:")
                Spacer()
                Text(note.text)
            }
            
            HStack {
                ForEach(note.moods.compactMap { $0.display.first }, id: \.self) { string in
                    Text("\(string)")
                        .font(.caption2)
                        .padding(8)
                        .background(Material.ultraThinMaterial)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
        }
        .onTapGesture {
            sheet = true
        }
        .sectionShadow(innerPadding: theme.padding, margin: theme.padding)
        .sheet(isPresented: $sheet, onDismiss: {}, content: {
            EditNoteSheet(note: $note, allMoods: $allMoods, theme: theme, maxCharacters: maxCharacters)
        })
    }
    
    func formattedDate(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return formatter.string(from: date)
    }
}
