//
//  EditNoteSheet.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 29.10.24.
//
import SwiftUI
import SwiftData

struct EditNoteSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) private var theme

    @StateObject private var viewModel: EditNodeViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(note: Binding<Node>, allMoods: Binding<[Mood]>, maxCharacters: Int) { 
        let vm = ViewModelFactory.makeEditNoteViewModel(note: note.wrappedValue, allMoods: allMoods.wrappedValue, maxCharacters: maxCharacters)
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                theme.color.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: theme.layout.padding * 3) {
                        SheetInputField()
                        
                        ControllButton()
                        
                        MoodList()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                }
                .onTapGesture { isTextFieldFocused = false }
            }
        }
    }
    
    @ViewBuilder func SheetInputField() -> some View {
        VStack {
            HStack {
                FootLineText(DateFormatteUtil.formattedDateTimer(viewModel.note.date.toDate))
                
                Spacer()
            }
            VStack {
                HStack {
                    TextEditor(text: $viewModel.note.text)
                        .background(theme.color.surface)
                        .cornerRadius(theme.layout.radius)
                        .shadow(radius: 2)
                        .lineLimit(10, reservesSpace: true)
                        .frame(minHeight: 100)
                        .focused($isTextFieldFocused)
                }
                HStack {
                    Spacer()
                    Text(viewModel.textFieldDisplayLength)
                        .font(.caption)
                }
            }
        }
    }
    
    @ViewBuilder func ControllButton() -> some View {
        HStack {
            
            Spacer()
            
            TryButton(text: "Speichern") {
                guard viewModel.note.text.count >= 5 else { throw NoteError.invalidText }
                
                try viewModel.saveNote(modelContext: modelContext)
                
                dismiss()
            }
            .withErrorHandling()
            .buttonStyle(CapsuleButtonStyle())
        }
    }
    
    @ViewBuilder func MoodList() -> some View {
        VStack {
            HStack { 
                FootLineText("Ausgewählte Moods: \(viewModel.allMoods.filter { $0.isOnList == true }.count)")
                
                Spacer()
            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]
            ) {
                ForEach(viewModel.allMoods, id: \.display) { mood in 
                    FootLineText(mood.display, color: theme.color.onBackground)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .lineLimit(1, reservesSpace: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(viewModel.currentMoodListContainsMood(mood: mood) ? theme.color.primary : theme.color.surface )
                        .cornerRadius(100)
                        .onTapGesture { viewModel.onClickOnMood(mood: mood) }
                }
            }
        }
    }
} 
