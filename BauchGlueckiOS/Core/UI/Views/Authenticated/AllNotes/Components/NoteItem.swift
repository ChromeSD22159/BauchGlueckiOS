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
               
                Text(  DateFormatteUtil.formattedFullDate(note.date.toDate) )
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
            NavigationView {
                EditNoteSheet(note: $note, allMoods: $allMoods, theme: theme, maxCharacters: maxCharacters)
                    .navigationTitle("🗒️ Notiz vom \( DateFormatteUtil.formattedFullDate(note.date.toDate) )")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDragIndicator(.visible)
        })
    }
}
