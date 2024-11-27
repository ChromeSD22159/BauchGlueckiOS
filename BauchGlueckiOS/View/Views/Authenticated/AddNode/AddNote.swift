//
//  AddNode.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.10.24.
//
import SwiftUI
import SwiftData

#Preview{    
    AddNote(modelContext: localDataScource.mainContext)
}

struct AddNote: View {
    @Environment(\.theme) private var theme
    
    @StateObject private var viewModel: AddNodeViewModel
    @EnvironmentObject var services: Services
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ViewModelFactory.makeAddNoteViewModel(context: modelContext))
    }
    
    @State var overlay: Bool = false
    @State private var navigateToNextView = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                theme.color.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: theme.layout.padding * 3) {
                        
                        InputField()
                        
                        ControllButton()
                        
                        MoodList(viewModel: viewModel)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                }
                .onTapGesture { isTextFieldFocused = false }
                .opacity(overlay ? 0.5 : 1.0)
                .animation(.easeInOut, value: overlay)
                
                if overlay {
                    AddNoteSaveOverlay(geo: geo, viewModel: viewModel, overlay: $overlay)
                }
            }
        }
    }
    
    @ViewBuilder func InputField() -> some View {
        VStack {
            HStack {
                FootLineText(Date().formatDateDDMM)
                
                Spacer()
            }
            VStack {
                HStack {
                    TextEditor(text: $viewModel.noteText)
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
            IconTextButton(text: "Abbrechen", onEditingChanged: {
                overlay = false
                
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    navigateToNextView = true
                }
            })
            
            Spacer()
            
            TryButton(text: "Speichern") {
                overlay = true

                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                   overlay = false
                }

                try viewModel.saveNode()

                Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { _ in
                    navigateToNextView = true
                }
            }
            .withErrorHandling()
            .buttonStyle(CapsuleButtonStyle())
        }.navigationDestination(isPresented: $navigateToNextView, destination: {
            HomeScreen(page: .home, services: services).navigationBarBackButtonHidden()
        })
    }
    
   
}
 
private struct AddNoteSaveOverlay: View {
    let geo: GeometryProxy
    var viewModel: AddNodeViewModel
    @Binding var overlay: Bool
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Notiz wird gespeichert!")
            
            FootLineText(viewModel.message, color: .red)
        }
        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
        .background(Material.ultraThinMaterial)
        .cornerRadius(geo.size.width * 0.8 / 10)
        .shadow(radius: 20)
        .animation(.easeInOut, value: overlay)
    }
}

private struct MoodList: View {
    var viewModel: AddNodeViewModel
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack {
            HStack {
                FootLineText("Ausgewählte Moods: \(viewModel.allMoods.filter { $0.isOnList == true }.count )")
                
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
