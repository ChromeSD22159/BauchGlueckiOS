//
//  AddNode.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.10.24.
//
import SwiftUI
import SwiftData

#Preview{    
    AddNode(modelContext: localDataScource.mainContext)
}

struct AddNode: View {
    let theme = Theme.shared
    
    @StateObject private var vm: AddNodeViewModel

    init(modelContext: ModelContext) {
        _vm = StateObject(wrappedValue: AddNodeViewModel(modelContext: modelContext))
    }
    
    @Environment(\.dismiss) var dismiss
    
    @State var overlay: Bool = false
    @State private var navigateToNextView = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: theme.padding * 3) {
                        
                        ImputField()
                        
                        ControllButton()
                        
                        MoodList()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                }
                .opacity(overlay ? 0.5 : 1.0)
                .animation(.easeInOut, value: overlay)
                
                if overlay {
                    SaveOverlay(geo: geo)
                }
            }
        }
    }
    
    @ViewBuilder func ImputField() -> some View {
        VStack {
            HStack {
                Text(vm.formattedDate())
                    .font(.footnote)
                Spacer()
            }
            VStack {
                HStack {
                    TextEditor(text: $vm.message)
                        .background(theme.surface)
                        .cornerRadius(theme.radius)
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    //vm.saveNode()
                    overlay = false
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8, execute: {
                    navigateToNextView = true
                })
            })
        }.navigationDestination(isPresented: $navigateToNextView, destination: {
            HomeScreen(page: .home).navigationBarBackButtonHidden()
        })
       
    }
    
    @ViewBuilder func SaveOverlay(geo: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Speichern")
        }
        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
        .background(Material.ultraThinMaterial)
        .cornerRadius(geo.size.width * 0.8 / 10)
        .shadow(radius: 20)
        .animation(.easeInOut, value: overlay)
    }
    
    @ViewBuilder func MoodList() -> some View {
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
                        .background( Material.ultraThickMaterial.opacity(vm.currentMoodListContainsMood(mood: mood) ? 1.0 : 0.3) )
                        .cornerRadius(100)
                        .onTapGesture { vm.onClickOnMood(mood: mood) }
                }
            }
        }
    }
}



