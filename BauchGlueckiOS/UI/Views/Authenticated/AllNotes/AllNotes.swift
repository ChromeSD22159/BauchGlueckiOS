//
//  AllNotes.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.10.24.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct AllNotes: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) var modelContext
    
    @Query(
        transaction: .init(animation: .bouncy)
    ) var notes: [Node]
    
    init() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        let predicate = #Predicate<Node> { note in
            note.userID == userID
        }
        
        self._notes = Query(
            filter: predicate,
            sort: \.date
        )
    }
    
    var body: some View {
        ZStack {
            theme.color.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: theme.layout.padding * 3) {
                    
                    ForEach(notes) { note in
                        NoteItem(note: note)
                    }
                    
                }.padding(.top, theme.layout.padding)
            }
        }
    }
}
