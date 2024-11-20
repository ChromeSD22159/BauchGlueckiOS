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
    
    @StateObject private var vm: AddNodeViewModel

    init(modelContext: ModelContext) {
        _vm = StateObject(wrappedValue: AddNodeViewModel(modelContext: modelContext))
    }
    
    @State var overlay: Bool = false
    @State private var navigateToNextView = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                theme.color.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: theme.layout.padding * 3) {
                        
                        InputField()
                        
                        ControllButton()
                        
                        MoodList(vm: vm)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                }
                .opacity(overlay ? 0.5 : 1.0)
                .animation(.easeInOut, value: overlay)
                
                if overlay {
                    AddNoteSaveOverlay(geo: geo, vm: vm, overlay: $overlay)
                }
            }
        }
    }
    
    @ViewBuilder func InputField() -> some View {
        VStack {
            HStack {
                Text(vm.formattedDate())
                    .font(.footnote)
                Spacer()
            }
            VStack {
                HStack {
                    TextEditor(text: $vm.node)
                        .background(theme.color.surface)
                        .cornerRadius(theme.layout.radius)
                        .shadow(radius: 2)
                        .lineLimit(10, reservesSpace: true)
                        .frame(minHeight: 100)
                }
                HStack {
                    Spacer()
                    Text(vm.textFieldDisplayLength)
                        .font(.caption)
                }
            }
        }
    }
    
    @ViewBuilder func ControllButton() -> some View {
        HStack {
            IconTextButton(text: "Abbrechen", onEditingChanged: {
                overlay = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    navigateToNextView = true
                })
            })
            
            Spacer()
            
            IconTextButton(text: "Speichern", onEditingChanged: {
                overlay = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    vm.saveNode() {
                        overlay = false
                        
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                            navigateToNextView = true
                        }
                    }
                    
                })
            })
        }.navigationDestination(isPresented: $navigateToNextView, destination: {
            HomeScreen(page: .home).navigationBarBackButtonHidden()
        })
    }
    
}
 
private struct AddNoteSaveOverlay: View {
    let geo: GeometryProxy
    var vm: AddNodeViewModel
    @Binding var overlay: Bool
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Notiz wird gespeichert!")
            
            Text(vm.message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
        .background(Material.ultraThinMaterial)
        .cornerRadius(geo.size.width * 0.8 / 10)
        .shadow(radius: 20)
        .animation(.easeInOut, value: overlay)
    }
}

private struct MoodList: View {
    var vm: AddNodeViewModel
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack {
            HStack {
                Text("Ausgewählte Moods: \(vm.allMoods.filter { $0.isOnList == true }.count )")
                    .font(.footnote)
                
                Spacer()
            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]
            ) {
                ForEach(vm.allMoods, id: \.display) { mood in
                    Text(mood.display)
                        .font(.footnote)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .lineLimit(1, reservesSpace: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(theme.color.onBackground)
                        .background(vm.currentMoodListContainsMood(mood: mood) ? theme.color.primary : theme.color.surface )
                        .cornerRadius(100)
                        .onTapGesture { vm.onClickOnMood(mood: mood) }
                }
            }
        }
    }
}
